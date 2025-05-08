# frozen_string_literal: true

module ExploreQueues
  class DeleteCommand < BaseCommand
    attr_reader :user_game, :explore_queues

    def initialize(user_game:, explore_queues:)
      @user_game = user_game
      @explore_queues = explore_queues

      super()
    end

    def call
    rescue StandardError => e
      @errors << e.message
    end
  end
end
