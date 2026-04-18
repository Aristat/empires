# PRD: Protection Turns

## 1. Overview

New players joining a game are vulnerable to being attacked immediately by established players, which creates a poor onboarding experience. This feature introduces a **protection period** for each `UserGame`: a configurable number of turns during which the player cannot be targeted by any attack (army, catapult, or thief).

Each game has a `protection_turns` setting (default: 200) configured alongside `max_turns` when the game is set up. When a `UserGame` is created it receives this value as its own `protection_turns` counter. Every time the player ends a turn, their counter decrements by 1 until it reaches 0 — at which point protection is permanently lifted and they become attackable.

Protected players are visually highlighted in the scoreboard so all players know who cannot be attacked yet.

---

## 2. Actors

| Actor | Role |
|---|---|
| **User (player)** | Plays the game; benefits from protection as a new player; blocked from attacking protected targets |
| **System** | Decrements `protection_turns` on each `EndTurn`; enforces protection check in all attack commands |

---

## 3. Data Model

### 3a. `games` table — `settings` jsonb

Add a new key to the `settings` jsonb column (no migration needed — already jsonb):

```json
{ "protection_turns": 200 }
```

- Set alongside `max_turns` in `Games::CreateBuildingsCommand` (or wherever game defaults are seeded).
- Default value: `200`.
- Accessed as: `game.settings['protection_turns'].to_i` (fall back to `200` if nil).

### 3b. `user_games` table — new integer column

```ruby
add_column :user_games, :protection_turns, :integer, default: 0, null: false
```

- Set at `UserGame` creation time to `game.settings['protection_turns'].to_i`.
- Decremented by 1 per `EndTurn` call while `> 0`.
- Never goes below `0`.
- A value of `0` means protection is fully expired.

### 3c. Migration

```ruby
# db/migrate/YYYYMMDDHHMMSS_add_protection_turns_to_user_games.rb
class AddProtectionTurnsToUserGames < ActiveRecord::Migration[8.0]
  def change
    add_column :user_games, :protection_turns, :integer, default: 0, null: false
  end
end
```

---

## 4. Command Objects

### 4a. `Games::SetupProtectionTurnsCommand` _(new)_

**Namespace:** `app/commands/games/`
**Responsibility:** Called when a `UserGame` is created (player joins a game). Reads `game.settings['protection_turns']` and writes it to `user_game.protection_turns`.

```ruby
# Usage: Games::SetupProtectionTurnsCommand.new(user_game: ug).call
```

- If `game.settings['protection_turns']` is nil or 0, sets `protection_turns` to `0` (no protection).
- Saves the `user_game`.

### 4b. `UserGames::EndTurnCommand` _(modify existing)_

**Change:** In the turn-processing block where `@user_game.turn += 1` occurs, add:

```ruby
@user_game.protection_turns -= 1 if @user_game.protection_turns > 0
```

This ensures protection decrements exactly once per turn, in sync with the turn counter.

### 4c. `AttackQueues::CreateArmyAttackCommand` _(modify existing)_

**Change:** In `validate_attack`, add early check:

```ruby
if to_user_game.protection_turns > 0
  @errors << "#{to_user_game.user.email} is under protection for #{to_user_game.protection_turns} more turns and cannot be attacked."
end
```

Add before the self-attack check so it's the first error raised for protected targets.

### 4d. `AttackQueues::CreateCatapultAttackCommand` _(modify existing)_

**Change:** Same protection check as 4c, added to its `validate_attack` method.

### 4e. `AttackQueues::CreateThiefAttackCommand` _(modify existing)_

**Change:** Same protection check as 4c, added to its `validate_attack` method.

### 4f. `Games::PrepareScoresCommand` _(modify existing)_

**Change:** Add `under_protection` boolean to each player hash:

```ruby
{
  ...
  under_protection: user_game.protection_turns > 0,
  protection_turns_remaining: user_game.protection_turns
}
```

---

## 5. API / Controller Changes

### 5a. No new endpoints required.

The protection check happens inside existing attack commands — the controller already delegates to commands and renders `cmd.errors` on failure. No controller changes needed.

### 5b. Game setup / seed data

Wherever game data is seeded (e.g. `Games::CreateBuildingsCommand` or a seeds/rake task that configures `game.settings`), ensure `protection_turns: 200` is written to `game.settings` alongside `max_turns`. Example:

```ruby
game.update!(settings: game.settings.merge('protection_turns' => 200))
```

---

## 6. Acceptance Criteria

### Protection setup
- [ ] When a `UserGame` is created, `protection_turns` equals `game.settings['protection_turns']` (e.g. 200).
- [ ] If `game.settings['protection_turns']` is not set, `protection_turns` defaults to `0`.

### Turn decrement
- [ ] After each successful `EndTurn`, `protection_turns` decreases by exactly 1 (if `> 0`).
- [ ] `protection_turns` never goes below `0`.
- [ ] A player with `protection_turns = 0` remains at `0` after `EndTurn`.

### Attack blocking — army
- [ ] `CreateArmyAttackCommand` returns error `"...is under protection for N more turns..."` when `to_user_game.protection_turns > 0`.
- [ ] Attack succeeds normally when `to_user_game.protection_turns == 0`.

### Attack blocking — catapult
- [ ] `CreateCatapultAttackCommand` returns the same protection error for protected targets.

### Attack blocking — thief
- [ ] `CreateThiefAttackCommand` returns the same protection error for protected targets.

### Self-attack still blocked separately
- [ ] Attempting to attack yourself still returns the self-attack error, not the protection error.

### Scoreboard
- [ ] `PrepareScoresCommand` includes `under_protection: true` and `protection_turns_remaining: N` for players with `protection_turns > 0`.
- [ ] `PrepareScoresCommand` includes `under_protection: false` for players with `protection_turns == 0`.
- [ ] Scoreboard row for a protected player renders with the amber/warning color class (`table-warning`).
- [ ] Scoreboard row for a protected player shows the turns-remaining count (e.g. `🛡 180` or similar).
- [ ] Legend in the scoreboard already mentions "Under Protection" — ensure it is displayed.
- [ ] Current player's own row still uses the info color (`table-info`) when they are also under protection (info takes priority).

### Game settings
- [ ] `game.settings['protection_turns']` is set to `200` for all newly seeded/created games.
- [ ] The `max_turns` and `protection_turns` settings are visible in the game setup / admin area (non-goal to build UI — just ensure value is readable from `game.settings`).

---

## 7. Non-Goals

- **No admin UI** for editing `protection_turns` per game via a browser form — value is set in seed data / console.
- **No manual opt-out** — players cannot waive their own protection early.
- **No retroactive protection** — existing `user_games` with `protection_turns = 0` (default) are not granted protection by the migration.
- **No protection against aid or messages** — only attacks (army, catapult, thief) are blocked.
- **No "vacation mode"** — the scoreboard legend already mentions vacation mode as a separate concept; this feature does not implement it.
- **No notification system** — players are not emailed or flash-notified when their protection expires.
- **No fractional protection** — protection is purely turn-count based, not time-based.
