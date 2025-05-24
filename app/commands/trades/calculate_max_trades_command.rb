# frozen_string_literal: true

module Trades
  class CalculateMaxTradesCommand < BaseCommand
    DEFAULT_MAX_TRADES = 50

    attr_reader :user_game, :buildings

    def initialize(user_game:, buildings:)
      @user_game = user_game
      @buildings = buildings
    end

    def call
      base_trades = user_game.market * buildings[:town_center][:settings][:max_local_trades]
      base_trades = DEFAULT_MAX_TRADES if base_trades.zero?
      base_trades.round
    end
  end
end
