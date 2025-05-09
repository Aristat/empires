module UserGames
  class UpdateTurnsCommand
    attr_reader :game, :user_game

    def initialize(game:, user_game:)
      @game = game
      @user_game = user_game
    end

    def call
      current_time = Time.current
      diff_seconds = current_time - user_game.last_turn_at
      new_turns = (diff_seconds / game.seconds_per_turn).to_i
      return if new_turns <= 0

      player_turns = user_game.current_turns + new_turns
      if player_turns > game.max_turns
        player_turns = game.max_turns
      end

      user_game.update(current_turns: player_turns, last_turn_at: current_time)
    end
  end
end
