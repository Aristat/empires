Use the `project-context` skill and read `.claude/agents/code-tester.md` for context.

Write RSpec tests for: $ARGUMENTS

Follow the tester agent workflow:
1. Read the target file completely
2. Identify all public methods and behaviors to test
3. Check if a FactoryBot factory exists — create one if not
4. Write specs in the matching spec/ path mirroring app/ structure
5. Cover: happy path, edge cases, failure cases, side effects

For command objects, test with:
  cmd = described_class.new(user_game: create(:user_game), ...).call
  expect(cmd.success?).to be true
  expect(cmd.errors).to be_empty

Output a summary of spec files created and estimated coverage.
