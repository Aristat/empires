# frozen_string_literal: true

module Trades
  class GlobalWithdrawCommand < BaseCommand
    include ActionView::Helpers::NumberHelper

    attr_reader :user_game, :transfer_queue, :game_data, :messages

    def initialize(user_game:, transfer_queue:)
      @user_game = user_game
      @transfer_queue = transfer_queue
      @game_data = PrepareGameDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @messages = []

      super()
    end

    def call
      return if failed?

      update_params = {}
      withdraw_percentage = (100 - game_data[:global_withdraw_percent].to_f) / 100
      TransferQueue::RESOURCES.each do |resource_column|
        next if transfer_queue.send(resource_column).blank?

        update_params[resource_column] = user_game.send(resource_column) +
                                         (transfer_queue.send(resource_column) * withdraw_percentage).round
      end

      ActiveRecord::Base.transaction do
        user_game.update!(update_params) if update_params.present?
        transfer_queue.destroy!

        @messages << 'Resources successfully withdrawn from the market.'
      end
    rescue StandardError => e
      @errors << e.message
    end
  end
end
