---
name: project-context
description: Loads full domain knowledge for the Empires Rails game — models, command namespaces, DB schema, BaseCommand pattern, and key conventions. Use whenever working on this codebase.
user-invocable: false
---

# Project Context: Empires (Rails Game)

## Domain Overview
A turn-based strategy game. Players join `Game`s as `UserGame`s (choosing a `Civilization`),
manage resources/buildings/soldiers, explore land, trade, and attack each other.

## Key Models & Relationships
```
User          → has_many :user_games
Game          → has_many :user_games, :buildings, :soldiers, :civilizations
UserGame      → belongs_to :user, :game, :civilization
               → has_many :build_queues, :train_queues, :explore_queues
               → has_many :attack_queues (as attacker and defender)
Civilization  → belongs_to :game
Building      → belongs_to :game  (game-wide templates, keyed by string)
Soldier       → belongs_to :game  (game-wide templates, keyed by string)
AttackLog     → attacker_id / defender_id → user_games
```

## DB Schema Highlights
- `user_games` is the main gameplay table — holds all resource/building/soldier counts
  - Resources: food, wood, gold, iron, tools, wine, horses
  - Land types: f_land, m_land, p_land
  - Weapons: bows, swords, maces
  - Buildings stored as integer columns (tool_maker, gold_mine, farm, etc.)
  - `buildings_statuses`, `researches`, `trades`, `soldiers` stored as jsonb
- `attack_queues.attack_type` enum: army / catapult / thief
- `transfer_queues.transfer_type` enum: local / global trade
- Queue tables (build/train/explore/attack/transfer) always foreign-key to `user_game_id`

## Command Namespaces
| Namespace         | Path                              | Responsibility |
|-------------------|-----------------------------------|----------------|
| `Aids`            | app/commands/aids/                | Aid between players |
| `AttackQueues`    | app/commands/attack_queues/       | Queue/cancel attacks |
| `BuildQueues`     | app/commands/build_queues/        | Queue buildings |
| `ExploreQueues`   | app/commands/explore_queues/      | Queue land exploration |
| `Games`           | app/commands/games/               | Game setup (buildings, civs, soldiers, scores) |
| `Researches`      | app/commands/researches/          | Research level calculations |
| `Trades`          | app/commands/trades/              | Local + global market |
| `TrainQueues`     | app/commands/train_queues/        | Queue soldier training |
| `UserGames`       | app/commands/user_games/          | Core gameplay (end turn, attacks, scoring) |
| Root commands     | app/commands/                     | Cross-cutting: PrepareDataCommand, UpdateCountersCommand |

## BaseCommand Pattern
All commands inherit from `BaseCommand`:
```ruby
class SomeNamespace::SomeCommand < BaseCommand
  def initialize(user_game:, **other_args)
    super()          # sets @messages = [], @errors = []
    @user_game = user_game
  end

  def call
    # business logic
    # push to @errors on failure
    # push to @messages for user feedback
    self
  end
end
# Usage: cmd = SomeCommand.new(user_game: ug).call
#        cmd.success? / cmd.failed? / cmd.errors / cmd.messages
```

## Controller Conventions
- Thin controllers under `app/controllers/` (not API-only despite CLAUDE.md note — check actual routes)
- Always delegate to commands: `cmd = SomeCommand.new(...).call`
- Respond with `cmd.messages` / `cmd.errors` via JSON or redirect

## Query Objects
- `app/queries/` — `BaseQuery`, `UpdateCountersQuery`

## Key Computed Commands (pure calculation, no DB writes)
- `UserGames::HouseSpaceCommand` — max population
- `UserGames::TotalArmyCommand` — army strength
- `UserGames::TotalLandCommand` — total land
- `Researches::NextResearchLevelPointsCommand` — XP thresholds
- `Trades::MaxTradesCommand` — trade limits
- `TrainQueues::LimitForTrainCommand` / `SoldiersLimitCommand`

## Services
- `app/services/redis_lock_service.rb` — distributed Redis lock used to prevent race conditions on concurrent game state mutations
  - `RedisLockService.with_locks(*keys)` — acquires multiple locks in sorted-key order (deadlock-safe)
  - `call_without_lock` — tries once, returns `false` if lock is held
  - `call_with_lock(timeout:)` — polls until acquired or timeout expires

## Controller Helpers (ApplicationController)
- `with_user_game_lock(user_game)` — wraps a block in a Redis lock on `lock:user_game:<id>`, then re-fetches the record inside to avoid stale data. Use this in any controller action that mutates game state:
```ruby
def end_turn
  with_user_game_lock do |user_game|
    cmd = UserGames::EndTurnCommand.new(user_game: user_game).call
    render json: { messages: cmd.messages, errors: cmd.errors }
  end
end
```

## Testing Conventions
- Specs in `spec/` mirroring `app/` structure
- Factories in `spec/factories/`
- Commands tested as: `described_class.new(user_game: create(:user_game)).call`
- Use `shoulda-matchers` for model validations/associations
