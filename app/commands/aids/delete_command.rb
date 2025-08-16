# frozen_string_literal: true

module Aids
  class DeleteCommand < BaseCommand
    attr_reader :user_game, :transfer_queues

    CANCEL_TIME_LIMIT = 15.minutes.freeze

    def initialize(user_game:, transfer_queues:)
      @user_game = user_game
      @transfer_queues = transfer_queues

      super()
    end

    def call
      ActiveRecord::Base.transaction do
        transfer_queues.each do |transfer_queue|
          cancel_aid(transfer_queue)
        end
      end
    rescue StandardError => e
      @errors << e.message
    end

    private

    def cancel_aid(transfer_queue)
      unless transfer_queue.turns_remaining == 3 && transfer_queue.created_at > CANCEL_TIME_LIMIT.ago
        @errors << 'This aid cannot be cancelled anymore.'
        return
      end

      # Refund resources to sender
      refund_params = {}
      UserGame::AID_RESOURCES.each do |resource|
        amount = transfer_queue.send(resource) || 0
        next if amount.zero?

        # Apply reverse of 5% fee (divide by 0.95 to get original amount)
        original_amount = (amount / 0.95).round
        refund_params[resource] = user_game.send(resource) + original_amount
      end

      # Update user's resources if there's anything to refund
      user_game.update!(refund_params) if refund_params.present?

      # Delete the transfer queue
      transfer_queue.destroy!

      @messages << "Aid to empire ##{transfer_queue.to_user_game_id} has been cancelled."
    end
  end
end
