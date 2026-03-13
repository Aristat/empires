# frozen_string_literal: true

module TrainQueues
  class SoldiersLimitCommand < BaseCommand
    attr_reader :user_game, :buildings

    def initialize(user_game:, buildings:)
      @user_game = user_game
      @buildings = buildings
    end

    def call
      fort_capacity = user_game.fort * buildings[:fort][:settings][:max_units]
      fort_capacity = fort_capacity + (fort_capacity * (user_game.fort_space_researches / 100.0)).round
      user_game.town_center * buildings[:town_center][:settings][:max_units] + fort_capacity
    end
  end
end
