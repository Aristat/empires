module UserGames
  class TotalArmyCommand
    attr_reader :user_game

    def initialize(user_game:)
      @user_game = user_game
    end

    def call
      user_game.unique_unit_soldiers + user_game.archer_soldiers + user_game.swordsman_soldiers +
        user_game.horseman_soldiers + user_game.catapult_soldiers + user_game.macemen_soldiers +
        user_game.thieve_soldiers + user_game.trained_peasant_soldiers
    end
  end
end
