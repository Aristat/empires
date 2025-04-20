module Games
  class EndTurnCommand
    def initialize(user_game:)
      @user_game = user_game
    end

    def call
      return false if @user_game.nil? || @user_game.current_turns <= 0

      @user_game.with_lock do
        @user_game.turn += 1
        @user_game.current_turns -= 1
        @user_game.save!
      end

      true
    end
  end
end 