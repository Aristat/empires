# PRD: Users Score Table

## Overview
Add a dedicated, standalone scores endpoint for a game that returns a ranked leaderboard of all players with their score breakdown. Currently, score data is embedded inside the full game page via `PrepareUserDataCommand#prepare_users`, which requires loading all game data. This feature extracts scores into a focused, independently-accessible endpoint.

## Background
- Score is already stored in `user_games.score` (bigint, default 0)
- Score is calculated by `UserGames::UpdateScoreCommand` (buildings + land + resources)
- Scores are currently displayed via `app/views/games/_scores.html.erb` partial, embedded in the full game view
- No dedicated route or controller for scores exists today

## Goals
- Expose `GET /games/:id/scores` — returns a ranked leaderboard for the given game
- Keep the endpoint thin: delegate all data logic to a new query/command object
- Return HTML (rendered via a dedicated partial or view)
- The endpoint is accessible to any authenticated user, not just participants

## Non-Goals
- Score recalculation is **not** triggered by this endpoint (score is updated on end-turn)
- No pagination — all players fit in one table for a typical game
- No real-time push/websocket updates
- No global cross-game leaderboard
- No score editing or admin override

## Data Model
No schema changes required. Uses existing `user_games` table:
- `score` (bigint) — pre-calculated total score
- `m_land + f_land + p_land` — total land (derived)
- `researches` (jsonb) — for research level count
- `updated_at` — used to determine online status (within 10 minutes)

Associations used:
- `user_games belongs_to :user` → `user.email`
- `user_games belongs_to :civilization` → `civilization.name`
- `game has_many :user_games`

## Endpoint

### `GET /games/:id/scores`
Returns the ranked scores table for the game.

**Auth:** Requires `authenticate_user!` (Devise session)

**Route:**
```ruby
resources :games, only: [:show] do
  member do
    get :scores        # NEW
    get :select_civilization
    post :join
    post :end_turn
  end
end
```

**Controller:** `GamesController#scores`

```ruby
def scores
  @scores_data = Games::PrepareScoresCommand.new(game: @game, current_user_game: @user_game).call
end
```

**Response:** Renders `app/views/games/scores.html.erb`

## Business Logic — `Games::PrepareScoresCommand`

Located at `app/commands/games/prepare_scores_command.rb`

Inputs:
- `game:` — the Game record
- `current_user_game:` — the current user's UserGame (may be nil if user is not a participant)

Returns a hash:
```ruby
{
  total_players: Integer,
  online_players: Integer,
  current_user_game_id: Integer | nil,
  players: [
    {
      rank: Integer,           # 1-based position ordered by score desc
      id: Integer,             # user_game.id
      email: String,           # user.email
      civilization: String,    # civilization.name
      score: Integer,          # user_game.score
      total_land: Integer,     # m_land + f_land + p_land
      research_levels: Integer, # sum of all research level values
      online: Boolean          # updated_at >= 10.minutes.ago
    },
    ...
  ]
}
```

**Ordering:** players ordered by `score DESC`, ties broken by `id ASC`

**Online threshold:** `user_game.updated_at >= 10.minutes.ago` (consistent with existing code)

**Research levels:** `UserGame::RESEARCHES.keys.sum { user_game.send("#{_1}_researches").to_i }` (consistent with existing `prepare_users`)

**Query:** Use a single `includes(:user, :civilization).order(score: :desc, id: :asc)` to avoid N+1

## View

### `app/views/games/scores.html.erb`
Standalone page (not a partial) that renders the scores table.

Columns:
| # | Player | Civilization | R/L | Land | Score |
|---|--------|-------------|-----|------|-------|

- Row highlighted with `table-info` CSS class if `player[:id] == @scores_data[:current_user_game_id]`
- `*` appended to player name if online
- Numbers formatted with `number_with_delimiter`
- No "Actions" column (that is on the main game page)
- Shows "N players in game, M online" summary above table

### Navigation
Add a "Scores" link in the existing game navigation tabs (in `app/views/games/show.html.erb` or the layout partial that renders tabs).

## Acceptance Criteria

### Happy path
- **AC1:** `GET /games/:id/scores` returns HTTP 200 for an authenticated user who is a game participant
- **AC2:** `GET /games/:id/scores` returns HTTP 200 for an authenticated user who is NOT a game participant (spectator)
- **AC3:** The table lists all players ordered by score descending
- **AC4:** The current user's row is highlighted with `table-info` class
- **AC5:** Players who updated their game within the last 10 minutes are marked with `*`
- **AC6:** Total player count and online count are displayed above the table
- **AC7:** Research levels displayed match the sum of all research values for each player

### Error cases
- **AC8:** `GET /games/:id/scores` redirects to login for unauthenticated users (Devise default)
- **AC9:** `GET /games/:id/scores` returns HTTP 404 if `game_id` does not exist

### Performance
- **AC10:** Query uses a single DB call with `includes(:user, :civilization)` — no N+1 queries

## Files to Create / Modify

### New files
- `app/commands/games/prepare_scores_command.rb`
- `app/views/games/scores.html.erb`
- `spec/commands/games/prepare_scores_command_spec.rb`
- `spec/requests/games_scores_spec.rb`

### Modified files
- `config/routes.rb` — add `get :scores` member route
- `app/controllers/games_controller.rb` — add `scores` action, add `:scores` to `before_action :set_user_game`

## Test Plan

### `spec/commands/games/prepare_scores_command_spec.rb`
- Returns players ordered by score descending
- Ties broken by id ascending
- `rank` starts at 1
- `online: true` when updated_at < 10 min ago
- `online: false` when updated_at >= 10 min ago
- `current_user_game_id` set correctly when participant passed
- `current_user_game_id` is nil when nil passed (spectator)
- `total_players` equals the count of user_games for the game
- `online_players` counts correctly
- No N+1 queries (use `QueryCount` matcher or assert query count ≤ 2)

### `spec/requests/games_scores_spec.rb`
- GET /games/:id/scores — 200 for participant
- GET /games/:id/scores — 200 for non-participant authenticated user
- GET /games/:id/scores — redirects to login for unauthenticated user
- GET /games/:id/scores — 404 for non-existent game
- Response body contains player emails in score-descending order
- Response body highlights current user's row
