Use the `project-context` skill and read `.claude/agents/prd-writer.md` for context.

Create a PRD for this feature idea: $ARGUMENTS

Use the existing domain model (UserGame, Game, Building, Soldier, queues) where possible.
Do not invent new tables unless strictly necessary.

The PRD must include:
1. **Overview** — what the feature does and why
2. **Actors** — who uses it (User, Admin, System/background)
3. **Data Model** — new tables/columns or changes to existing ones (reference schema.rb)
4. **Command Objects** — list each command to be built with its namespace and responsibility
5. **API/Controller Changes** — endpoints, params, responses
6. **Acceptance Criteria** — specific, testable, includes error cases
7. **Non-Goals** — what is explicitly out of scope

Save to `.claude/features/<kebab-case-name>.md`

Then print:
```
PRD created: .claude/features/<name>.md
To build: /build-feature $(cat .claude/features/<name>.md)
```
