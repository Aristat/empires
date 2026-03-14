# CLAUDE.md

## Project Overview
Empires — a turn-based strategy game built with Ruby on Rails.

## Tech Stack
- Ruby 3.3 / Rails 7.1
- PostgreSQL
- RSpec + FactoryBot + Shoulda Matchers
- ERB views (not API-only)

## Domain Context
The `project-context` skill provides full domain knowledge:
models, command namespaces, DB schema, BaseCommand pattern, and key conventions.

## Slash Commands (use in Claude Code)
| Command | Usage |
|---|---|
| `/refactor` | `/refactor app/commands/user_games/end_turn_command.rb` |
| `/write-tests` | `/write-tests app/commands/trades/global_buy_command.rb` |
| `/new-command` | `/new-command process thief attack result for user_game` |
| `/build-feature` | `/build-feature add alliance system between players` |
| `/prd` | `/prd let players send gifts to allies` |

## Multi-Agent System
5 agents under `.claude/agents/`:
- **orchestrator** → coordinates full pipeline ← start here for new features
- **code-architect** → designs and builds new features
- **write-tests** (code-tester.md) → writes and maintains RSpec tests
- **code-refactorer** → improves existing code quality
- **prd-writer** → turns rough ideas into complete PRDs

## How to Invoke Agents

### Full pipeline (recommended)
```bash
claude "$(cat .claude/agents/orchestrator.md)
Feature to build: [DESCRIBE FEATURE]"
```

### Individual agents
```bash
# Architect only
claude "$(cat .claude/agents/code-architect.md)
Feature to build: [DESCRIBE FEATURE]"

# Tests only
claude "$(cat .claude/agents/code-tester.md)
Write tests for: [FILE PATH or CLASS NAME]"

# Refactor only
claude "$(cat .claude/agents/code-refactorer.md)
Refactor this file: [FILE PATH]"

# PRD only
claude "$(cat .claude/agents/prd-writer.md)
Feature idea: [ROUGH DESCRIPTION]"
```

## Development Server
Do NOT start the Rails server or Tailwind watch process automatically.
The human runs both manually:
```bash
bin/rails server
bin/rails tailwindcss:watch
```

Do NOT run `bin/rails tailwindcss:build` manually — the watch process rebuilds CSS automatically on every file change, just need to refresh the page instead

## Playwright Testing
When using Playwright to verify UI, log in with:
- Email: `test@gmail.com`
- Password: `123456`

Save all screenshots to `.playwright-mcp/screenshots/` only.

## Project Conventions
- Command objects in `app/commands/<namespace>/`
- BaseCommand: inherit, call super() in initialize, return self from call
- Controllers under `app/controllers/` — thin, delegate to commands
- snake_case for files and methods
- Always write tests for new code
- Queries in `app/queries/`
