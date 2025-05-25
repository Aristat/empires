# frozen_string_literal: true

module TrainQueues
  class LimitForTrainCommand < BaseCommand
    attr_reader :user_game, :buildings

    def initialize(user_game:, buildings:)
      @user_game = user_game
      @buildings = buildings
    end

    def call
      user_game.town_center * buildings[:town_center][:settings][:max_train] +
        user_game.fort * buildings[:fort][:settings][:max_train]
    end
  end
end
