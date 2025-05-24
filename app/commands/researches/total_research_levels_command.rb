# frozen_string_literal: true

module Researches
  class TotalResearchLevelsCommand < BaseCommand
    attr_reader :user_game

    def initialize(user_game:)
      @user_game = user_game
    end

    def call
      user_game.attack_points_researches + user_game.defense_points_researches +
        user_game.thieves_strength_researches + user_game.military_losses_researches +
        user_game.food_production_researches + user_game.mine_production_researches +
        user_game.weapons_tools_production_researches + user_game.space_effectiveness_researches +
        user_game.markets_output_researches + user_game.explorers_researches +
        user_game.catapults_strength_researches + user_game.wood_production_researches
    end
  end
end
