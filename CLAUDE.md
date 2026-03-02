# CLAUDE.md

## Project Overview
Ruby on Rails project with multi-agent AI assistance.

## Tech Stack
- Ruby 3.3 / Rails 7.1
- PostgreSQL
- RSpec + FactoryBot + Shoulda Matchers
- API-only mode

## Multi-Agent System
This project uses 4 agents:
- **orchestrator** → coordinates all agents end-to-end ← start here
- **code-architect** → designs and builds new features
- **write-tests** → writes and maintains RSpec tests
- **code-refactorer** → improves existing code quality

## How to Invoke Agents

### 🥇 Full pipeline (recommended)
```bash
# Orchestrator runs all 3 agents automatically
claude "$(cat .claude/agents/orchestrator.md)
Feature to build: [DESCRIBE FEATURE]"
```

### 🔧 Individual agents (when needed)
```bash
# Architect only
claude "$(cat .claude/agents/code-architect.md)
Feature to build: [DESCRIBE FEATURE]"

# Tests only
claude "$(cat .claude/agents/write-tests.md)
Write tests for: [FILE PATH or CLASS NAME]"

# Refactor only
claude "$(cat .claude/agents/code-refactorer.md)
Refactor this file: [FILE PATH]"
```

## Project Conventions
- Commands objects in `app/commands/`
- Controllers under `app/controllers/api/v1/`
- snake_case for files and methods
- Thin controllers, fat commands objects
- Always write tests for new code
