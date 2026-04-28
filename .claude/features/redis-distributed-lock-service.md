# PRD: Redis Distributed Lock Service

## 1. Overview

### What
Replace the PostgreSQL row-level lock (`@user_game.with_lock do`) used in `UserGames::EndTurnCommand` with a Redis-based distributed lock implemented in a reusable `RedisLockService`.

### Why
`ActiveRecord#with_lock` issues a `SELECT FOR UPDATE` query, which holds a **database connection and a row lock** for the entire duration of the turn computation (~100–500 ms of business logic, DB writes, queue processing, and attack resolution). Under concurrent load (multiple players end turns simultaneously, or the same player double-submits) this causes:

- Long-held row locks blocking other queries on `user_games`
- A database connection consumed per in-flight turn for the full computation time
- No cross-process TTL safety — if the Rails process crashes mid-lock, Postgres releases it, but only when the connection is dropped, not after a deterministic timeout

A Redis distributed lock (`SET key NX PX <ttl>`) decouples the mutual-exclusion concern from the database layer, enables configurable expiry to protect against process crashes, and makes the locking mechanism usable across multiple app server instances without DB contention.

**No Redis infrastructure is currently present** — the app uses `solid_cache`, `solid_queue`, and `solid_cable`. Adding Redis is a deliberate infrastructure addition scoped to this feature.

---

## 2. Actors

| Actor | Role |
|---|---|
| **System (HTTP request)** | Player clicks "End Turn" → controller calls `EndTurnCommand` |
| **System (background job)** | Any future job that could call `EndTurnCommand` |
| **Developer** | Consumes `RedisLockService` in other commands where row-lock contention is a concern |

No end-user-facing UI changes.

---

## 3. Data Model

### No new database tables or columns.

### Redis key schema
| Key | Type | TTL | Description |
|---|---|---|---|
| `lock:user_game:<user_game_id>` | String (token) | 30 seconds (configurable) | Mutual exclusion token for a single user game's turn |

The value stored is a random token (UUID) so only the lock holder can release it (compare-and-delete via Lua script), preventing a slow process from deleting a lock acquired by a new holder after TTL expiry.

### Configuration
```ruby
# config/initializers/redis.rb
REDIS_LOCK_CLIENT = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"))
```

`REDIS_URL` is an environment variable; defaults to `redis://localhost:6379/1` for local dev.

---

## 4. New Service

### `app/services/redis_lock_service.rb`

**Responsibility**: Acquire and release a Redis distributed lock around a block. Implements the single-Redis-instance variant of the Redlock pattern (compare-and-delete via inline Lua script).

**Constructor**:
```ruby
RedisLockService.new(
  key:,           # String — Redis key, e.g. "lock:user_game:42"
  ttl: 30,        # Integer (seconds) — lock expiry; protects against process crashes
  timeout: nil    # Integer/Float (seconds) or nil — how long call_with_lock will poll
)
```

### Two public entry points

#### `call_without_lock { block }`
Try once. If the lock is free, acquire it, yield, release, return the block value.  
If already held, **return `false` immediately** without yielding.

```ruby
result = RedisLockService.new(key: lock_key, ttl: 30).call_without_lock do
  do_work
end
# => block return value, or false if lock was already held
```

#### `call_with_lock(timeout:) { block }`
Poll until the lock is free or `timeout` seconds have elapsed.  
`timeout` can also be passed to the constructor as a default and omitted here.  
If the lock is acquired within the timeout, yield and return the block value.  
If `timeout` elapses without acquiring, **return `false`**.

```ruby
result = RedisLockService.new(key: lock_key, ttl: 30).call_with_lock(timeout: 5) do
  do_work
end
# => block return value, or false if lock never freed within 5 s
```

Poll interval: 50 ms fixed (no exponential backoff — see Non-Goals).

**Internal contract for both methods**:
- Acquire: `SET key <uuid_token> NX PX <ttl_ms>`
- Release (in `ensure`): Lua compare-and-delete — `if redis.call("get", key) == token then return redis.call("del", key) end`
- If the block raises, the lock is released in `ensure` and the exception re-raised
- Only the token owner can release (UUID prevents a timed-out holder from deleting a new holder's lock)

### Namespace: `app/services/` (create directory if absent)

---

## 5. Modified Command

### `app/commands/user_games/end_turn_command.rb`

Replace lines 119–163 (`@user_game.with_lock do ... end`) with `call_without_lock` — the end-turn action should not queue behind another in-flight turn for the same player; a duplicate submission just returns `false`:

```ruby
def call
  return false if @user_game.current_turns <= 0

  lock_key = "lock:user_game:#{@user_game.id}"
  result = RedisLockService.new(key: lock_key, ttl: 30).call_without_lock do
    # ... all existing turn logic ...
    true
  end

  result == true
end
```

`EndTurnCommand#call` continues to return `true` on success and `false` when the turn cannot be processed (lock held or no turns remaining) — **no change to caller behavior**.

---

## 6. API / Controller Changes

**None.** The controller (`app/controllers/user_games_controller.rb` or equivalent) calls `EndTurnCommand.new(user_game:).call` and checks the boolean result. The lock is entirely internal to the command.

---

## 7. Acceptance Criteria

### Happy path
- [ ] `EndTurnCommand.new(user_game:).call` returns `true` when Redis is available, the lock is free, and the player has turns remaining
- [ ] The Redis key `lock:user_game:<id>` is set for the duration of the turn and deleted immediately after
- [ ] All existing `EndTurnCommand` specs pass unchanged

### Lock contention
- [ ] When the lock is already held (simulated by pre-seeding the Redis key), `EndTurnCommand#call` returns `false` without executing any turn logic
- [ ] The Redis key is **not** deleted by the contending caller
- [ ] No DB writes occur when the lock is not acquired

### TTL / crash safety
- [ ] The Redis key has a TTL ≤ 30 seconds (verified by PTTL after acquisition)
- [ ] If the block raises an exception, `ensure` in `RedisLockService` deletes the key and re-raises

### Token safety
- [ ] A second `RedisLockService` instance with a different token cannot delete a lock it did not acquire (Lua script compare-and-delete test)

### `RedisLockService` unit tests (`spec/services/redis_lock_service_spec.rb`)

**`call_without_lock`**
- [ ] Yields the block and returns the block value when lock is free
- [ ] Returns `false` immediately (< 5 ms) and does not yield when lock is already held
- [ ] No DB writes or side effects occur when lock is not acquired

**`call_with_lock`**
- [ ] Yields and returns the block value when lock becomes free before `timeout` elapses
- [ ] Returns `false` after `timeout` seconds when lock is never released (verified via elapsed time)
- [ ] Polls at ~50 ms intervals (not a busy-loop — verified by call count on Redis mock)
- [ ] `timeout` may be supplied at construction time or per-call; per-call takes precedence

**Both methods**
- [ ] Lock is released in `ensure` even when block raises; exception is re-raised
- [ ] Lock key has PTTL ≤ `ttl * 1000` ms after acquisition
- [ ] Token mismatch — a second service instance with a different token cannot delete the held lock

### Infrastructure
- [ ] `redis` gem added to `Gemfile`
- [ ] `REDIS_LOCK_CLIENT` initializer present in `config/initializers/redis.rb`
- [ ] `REDIS_URL` documented in `.env.example` (or equivalent)
- [ ] CI / local dev: lock tests use `mock_redis` or `fakeredis` gem (no real Redis required in test env)

---

## 8. Non-Goals

- **Not** replacing `solid_cache`, `solid_queue`, or `solid_cable` with Redis equivalents
- **Not** applying Redis locking to any command other than `EndTurnCommand` in this iteration
- **Not** implementing multi-node Redlock (Redlock with N Redis nodes for high-availability) — single Redis instance is sufficient
- **Not** adding exponential backoff to `call_with_lock` — fixed 50 ms poll interval is sufficient
- **Not** adding `call_with_lock` to `EndTurnCommand` in this iteration — the command uses `call_without_lock` (duplicate submissions must fail fast, not queue)
- **Not** changing the return type or public interface of `EndTurnCommand`
- **Not** removing the `@user_game.save!` DB transaction — the DB transaction inside `save!` remains; only the outer `with_lock` is replaced
