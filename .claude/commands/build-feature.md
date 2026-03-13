Use the `project-context` skill and read `.claude/agents/orchestrator.md` for context.

Run the full agent pipeline for this feature: $ARGUMENTS

Execute sequentially:

## Step 1 — Print execution plan
Before writing any code, print:
- Files the architect will create (migrations, models, commands, controllers, routes)
- Specs the tester will write
- Files the refactorer will review

Wait for user confirmation before proceeding.

## Step 2 — Architect (follow .claude/agents/code-architect.md)
- Create migrations with proper indexes on FK columns
- Create/update models with validations and associations
- Create command objects under the correct namespace (see project-context.md)
- Update controllers (thin — delegate to commands)
- Update routes

## Step 3 — Write Tests (follow .claude/agents/code-tester.md)
- Write specs for every new file created in Step 2
- Create factories for any new models
- Cover happy path, edge cases, failures

## Step 4 — Refactor (follow .claude/agents/code-refactorer.md)
- Review all newly written code
- Apply game-domain refactoring patterns
- Flag any remaining issues

## Step 5 — Final report
Print:
- Files created
- Tests written
- Refactors applied
- Manual steps (rails db:migrate, etc.)
