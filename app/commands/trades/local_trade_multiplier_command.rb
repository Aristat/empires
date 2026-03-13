# frozen_string_literal: true

module Trades
  class LocalTradeMultiplierCommand < BaseCommand
    # Each time the score exceeds this threshold (halved repeatedly), prices increase
    SCORE_PENALTY_THRESHOLD = 100_000
    # Score is halved each iteration to count how many doublings above threshold
    SCORE_HALVING_FACTOR = 2
    # Price multiplier added per doubling above threshold
    SCORE_PENALTY_INCREMENT = 0.05

    attr_reader :user_game

    def initialize(user_game:)
      @user_game = user_game
    end

    def call
      extra = 1.0
      s = user_game.score

      # Count how many times score exceeds the threshold when halved successively.
      # Each doubling above threshold adds SCORE_PENALTY_INCREMENT to buy price multiplier.
      while s > SCORE_PENALTY_THRESHOLD
        extra += SCORE_PENALTY_INCREMENT
        s /= SCORE_HALVING_FACTOR
      end

      extra
    end
  end
end
