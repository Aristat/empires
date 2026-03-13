Use the `project-context` skill and read `.claude/agents/code-refactorer.md` for context.

Refactor the following file: $ARGUMENTS

Follow the refactorer agent workflow exactly:
1. Read the file fully
2. Read related files (callers, base classes, similar commands in the same namespace)
3. List all issues found before making any changes
4. Refactor one concern at a time
5. Output a summary of every change made and why

Do not change behavior. Do not add tests.
