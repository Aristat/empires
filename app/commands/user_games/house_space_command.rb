module UserGames
  class HouseSpaceCommand
    attr_reader :user_game, :buildings

    def initialize(user_game:, buildings:)
      @user_game = user_game
      @buildings = buildings
    end

    def call
      house_space = user_game.house * buildings[:house][:settings][:people] +
        user_game.town_center * buildings[:town_center][:settings][:people]
      house_space + (house_space * (user_game.space_effectiveness_researches / 100.0)).round
    end
  end
end
