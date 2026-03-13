# PRD: Add New Research Types

## 1. Overview

The research system lets players invest `research_points` (produced by Mage Towers) into one of twelve permanent bonuses that improve over many turns. A `# TODO` in `app/models/user_game.rb` identifies six researches that are designed but not yet implemented:

- **Conquered Land** — increases land taken after a successful army attack
- **Army Upkeep Cost** — reduces the gold spent every turn maintaining soldiers
- **Army Training Cost** — reduces the resources spent when queuing new soldiers
- **Wine Production** — increases wine output from Wineries
- **Horses Production** — increases horse output from Stables
- **Fort Space** — increases how many soldiers each Fort building can hold

These six researches follow the **exact same mechanics** as the existing twelve: each level costs an exponentially growing number of research points, the player selects one at a time via `current_research`, and each level adds +1 to a counter stored in the `researches` JSONB column. Effects are percentage-based bonuses mirroring the existing patterns.

---

## 2. Actors

| Actor | Interaction |
|---|---|
| **Player (User)** | Selects a new research from the dropdown in the Research UI; benefits apply automatically each turn |
| **System (EndTurnCommand)** | Advances the current research level when enough points accumulate; applies wine/horses/upkeep bonuses |
| **System (AttackCommand)** | Applies `conquered_land` bonus when distributing land after a won battle |
| **System (TrainQueues::CreateCommand)** | Applies `army_training_cost` discount when player queues soldier training |
| **System (TrainQueues::SoldiersLimitCommand)** | Applies `fort_space` bonus to fort capacity |

---

## 3. Data Model

**No new tables or migrations required.** All changes are additive to existing constants and JSONB columns.

### `app/models/user_game.rb`

**`RESEARCHES` constant** — add 6 new keys (all default to `0`):
```ruby
conquered_land: 0,
army_upkeep_cost: 0,
army_training_cost: 0,
wine_production: 0,
horses_production: 0,
fort_space: 0
```

**`current_research` enum** — add 6 new values (next available integers are 12–17):
```ruby
conquered_land: 12,
army_upkeep_cost: 13,
army_training_cost: 14,
wine_production: 15,
horses_production: 16,
fort_space: 17
```

**Validations** — add caps matching `military_losses_researches` pattern:
```ruby
validates :army_upkeep_cost_researches,  numericality: { less_than_or_equal_to: 50 }
validates :army_training_cost_researches, numericality: { less_than_or_equal_to: 50 }
```
`conquered_land`, `wine_production`, `horses_production`, and `fort_space` have no cap (they scale indefinitely like attack/defense research).

---

## 4. Command Objects

### 4a. Commands to **modify**

| File | Change |
|---|---|
| `app/commands/researches/total_research_levels_command.rb` | Add 6 new accessors to the sum so research cost scaling accounts for new levels |
| `app/commands/user_games/end_turn_command.rb` | (a) Add 6 `when` branches in `update_researches`; (b) apply wine/horses/upkeep bonuses in their respective production methods |
| `app/commands/user_games/process_army_attack_command.rb` | Apply `conquered_land_researches` bonus to land distributed after attacker wins |
| `app/commands/train_queues/create_command.rb` | Apply `army_training_cost_researches` discount to all training resource costs |
| `app/commands/train_queues/soldiers_limit_command.rb` | Apply `fort_space_researches` bonus to the fort contribution of soldier capacity |
| `app/commands/prepare_user_data_command.rb` | Include 6 new research values in `prepare_research_data` for the UI |

### 4b. Bonus formulas (all follow existing pattern)

**`wine_production`** — in `end_turn_command.rb` winery production method:
```ruby
get_wine = get_wine + (get_wine * (user_game.wine_production_researches / 100.0)).round
```

**`horses_production`** — in `end_turn_command.rb` stable production method:
```ruby
get_horses = get_horses + (get_horses * (user_game.horses_production_researches / 100.0)).round
```

**`army_upkeep_cost`** — in `end_turn_command.rb` soldier upkeep deduction:
```ruby
upkeep_gold = (upkeep_gold - (upkeep_gold * (user_game.army_upkeep_cost_researches / 100.0))).round
```
Capped at level 50 (max 50% reduction), matching `military_losses` pattern.

**`army_training_cost`** — in `train_queues/create_command.rb` during resource calculation:
```ruby
@need_gold   = (@need_gold   - (@need_gold   * (user_game.army_training_cost_researches / 100.0))).round
@need_wood   = (@need_wood   - (@need_wood   * (user_game.army_training_cost_researches / 100.0))).round
@need_iron   = (@need_iron   - (@need_iron   * (user_game.army_training_cost_researches / 100.0))).round
# same for swords, bows, maces, horses
```
Capped at level 50 (max 50% reduction).

**`conquered_land`** — in `process_army_attack_command.rb` after successful attack:
```ruby
land_gained = land_gained + (land_gained * (attacker.conquered_land_researches / 100.0)).round
```

**`fort_space`** — in `train_queues/soldiers_limit_command.rb`:
```ruby
fort_capacity = user_game.fort * buildings[:fort][:settings][:max_units]
fort_capacity = fort_capacity + (fort_capacity * (user_game.fort_space_researches / 100.0)).round
user_game.town_center * buildings[:town_center][:settings][:max_units] + fort_capacity
```

### 4c. `update_researches` addition in `end_turn_command.rb`

Add 6 new `when` branches to the existing `case @user_game.current_research`:
```ruby
when 'conquered_land'        then @user_game.conquered_land_researches       += 1
when 'army_upkeep_cost'      then @user_game.army_upkeep_cost_researches      += 1
when 'army_training_cost'    then @user_game.army_training_cost_researches    += 1
when 'wine_production'       then @user_game.wine_production_researches       += 1
when 'horses_production'     then @user_game.horses_production_researches     += 1
when 'fort_space'            then @user_game.fort_space_researches            += 1
```

---

## 5. API / Controller Changes

No new endpoints or controllers are required. The existing flow already handles this:

| Existing endpoint | What it does | What changes |
|---|---|---|
| `PATCH /user_games/:id` | Sets `current_research` on the user_game | Now accepts 6 additional valid values for `current_research` param |
| `POST /user_games/:id/end_turn` | Runs `EndTurnCommand` | Command now processes 6 new `when` branches and applies new bonuses |

The `current_research` param is already permitted in `user_games_controller.rb`. The enum expansion is backward-compatible — old values retain their integer codes.

**View change:** `app/views/games/_research.html.erb` must add 6 new rows to the research table, with descriptions matching the bonus formula. Each row shows: research name, current level, effect description (e.g. "+X% wine production"), and the dropdown option.

---

## 6. Acceptance Criteria

### Research selection
- [ ] Player can select any of the 6 new research types from the `current_research` dropdown
- [ ] Selecting a new research type saves successfully (no validation errors)
- [ ] An invalid `current_research` value returns an error

### Research advancement (end of turn)
- [ ] When `current_research = 'wine_production'` and enough research_points accumulate, `wine_production_researches` increments by 1
- [ ] Same for all 6 new types: level increments exactly once per threshold crossed
- [ ] `TotalResearchLevelsCommand` includes all 6 new levels in its sum, increasing the cost of future research correctly

### Wine production bonus
- [ ] With `wine_production_researches = 10`, winery output increases by exactly 10% each turn
- [ ] With `wine_production_researches = 0`, winery output is unchanged

### Horses production bonus
- [ ] With `horses_production_researches = 20`, stable output increases by exactly 20% each turn
- [ ] With `horses_production_researches = 0`, stable output is unchanged

### Army upkeep cost reduction
- [ ] With `army_upkeep_cost_researches = 30`, gold spent on soldier upkeep per turn decreases by 30%
- [ ] `army_upkeep_cost_researches` cannot exceed 50 (validation error if attempted)
- [ ] With level 50, upkeep is exactly 50% of the base cost

### Army training cost reduction
- [ ] With `army_training_cost_researches = 25`, all training resource costs (gold, wood, iron, weapons, horses) decrease by 25%
- [ ] Costs are floored to 0, never negative
- [ ] `army_training_cost_researches` cannot exceed 50
- [ ] A player with otherwise insufficient resources but sufficient after the discount can train soldiers successfully

### Conquered land bonus
- [ ] With `conquered_land_researches = 15`, land distributed to the attacker after a won battle increases by 15%
- [ ] With `conquered_land_researches = 0`, conquered land is unchanged
- [ ] Bonus only applies to the attacker, not the defender

### Fort space bonus
- [ ] With `fort_space_researches = 20` and 10 forts (base max_units 15 each → 150 capacity), total fort capacity becomes 180
- [ ] Town center capacity is unaffected by `fort_space_researches`
- [ ] Player cannot queue training beyond the new fort capacity limit

### View
- [ ] Research UI table shows all 18 research types (12 existing + 6 new)
- [ ] Each new research row displays: name, current level, current bonus value, description
- [ ] New types appear in the `current_research` dropdown

---

## 7. Non-Goals

- **No migration** — all data lives in the existing `researches` JSONB column
- **No retroactive rebalancing** — existing research levels and costs are not changed
- **No UI redesign** — the research table is extended, not redesigned
- **No per-civilization overrides** for the new research bonuses (existing researches don't have them either)
- **No cap on `conquered_land`, `wine_production`, `horses_production`, `fort_space`** — these scale indefinitely like attack/defense researches
- **No new Researches:: command objects** — `TotalResearchLevelsCommand` and `NextResearchLevelPointsCommand` are modified in place, no new commands needed
- **No changes to the global trade system, aid system, or attack queue creation** — only the attack resolution and train queue creation are affected
