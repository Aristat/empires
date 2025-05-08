module UserGames
  class CalculateFoodPerExplorerCommand
    attr_reader :user_game, :buildings, :game_data

    def initialize(user_game:, buildings:, game_data:)
      @user_game = user_game
      @buildings = buildings
      @game_data = game_data
    end

    def call
      total_land = UserGames::CalculateTotalLandCommand.new(user_game: user_game).call
      extra_food_per_land = (total_land.to_f / game_data[:extra_food_per_land]).ceil
      buildings[:town_center][:settings][:food_per_explorer] + extra_food_per_land
    end
  end
end
