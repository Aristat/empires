# frozen_string_literal: true

module Trades
  class CalculateLocalTradeMultiplierCommand < BaseCommand
    attr_reader :user_game

    def initialize(user_game:)
      @user_game = user_game
    end

    def call
      extra = 1.0
      s = user_game.score

      while s > 100000
        extra += 0.05
        s /= 2
      end

      extra
    end
  end
end
