Read `.claude/context/project-context.md` for context on command conventions.

Scaffold a new command object based on this description: $ARGUMENTS

Rules:
- Determine the correct namespace from the description (aids, attack_queues, build_queues,
  explore_queues, games, researches, trades, train_queues, user_games, or root-level)
- Place the file at: app/commands/<namespace>/<snake_case_name>_command.rb
- Inherit from BaseCommand
- Use keyword arguments in initialize
- Always return self from call
- Push to @errors on failure, @messages for user-visible feedback
- Include only the skeleton + relevant domain logic stubs

Example structure:
```ruby
# app/commands/user_games/some_action_command.rb
module UserGames
  class SomeActionCommand < BaseCommand
    def initialize(user_game:)
      super()
      @user_game = user_game
    end

    def call
      return self unless valid?
      perform_action
      self
    end

    private

    def valid?
      # guard checks → push to @errors if invalid
      true
    end

    def perform_action
      # core logic
    end
  end
end
```

After creating the file, remind the user to run /write-tests for it.
