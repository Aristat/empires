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
      return if failed?

      ActiveRecord::Base.transaction do
        explore_queues.each do |explore_queue|
          delete_resources(explore_queue)
        end
      end
    rescue StandardError => e
      @errors << e.message
    end

    private

    def can_cancel?(explore_queue)
      return false if explore_queue.turns_used.positive?
      return false if explore_queue.created_at < 15.minutes.ago

      true
    end

    def delete_resources(explore_queue)
      return unless can_cancel?(explore_queue)

      @user_game.update!(
        food: @user_game.food + explore_queue.food,
        horses: @user_game.horses + explore_queue.horses,
        people: @user_game.people + explore_queue.people
      )

      explore_queue.destroy!
    end
  end
end
