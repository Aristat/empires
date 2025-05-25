# frozen_string_literal: true

module TrainQueues
  class DeleteCommand < BaseCommand
    attr_reader :user_game, :train_queue, :soldiers

    def initialize(user_game:, train_queue:)
      @user_game = user_game
      @train_queue = train_queue
      @soldiers = PrepareSoldiersDataCommand.new(civilization: user_game.civilization).call.with_indifferent_access

      super()
    end

    def call
      return if failed?

      ActiveRecord::Base.transaction do
        soldier = soldiers[train_queue.soldier_key]
        if soldier.present?
          update_params = {}

          unless soldier[:settings][:train_gold].zero?
            update_params[:gold] = user_game.gold + (soldier[:settings][:train_gold] * train_queue.quantity)
          end

          unless soldier[:settings][:train_wood].zero?
            update_params[:wood] = user_game.wood + (soldier[:settings][:train_wood] * train_queue.quantity)
          end

          unless soldier[:settings][:train_iron].zero?
            update_params[:iron] = user_game.iron + (soldier[:settings][:train_iron] * train_queue.quantity)
          end

          unless soldier[:settings][:train_swords].zero?
            update_params[:swords] = user_game.swords + (soldier[:settings][:train_swords] * train_queue.quantity)
          end

          unless soldier[:settings][:train_bows].zero?
            update_params[:bows] = user_game.bows + (soldier[:settings][:train_bows] * train_queue.quantity)
          end

          unless soldier[:settings][:train_maces].zero?
            update_params[:maces] = user_game.maces + (soldier[:settings][:train_maces] * train_queue.quantity)
          end

          unless soldier[:settings][:train_horses].zero?
            update_params[:horses] = user_game.horses + (soldier[:settings][:train_horses] * train_queue.quantity)
          end

          update_params[:people] = user_game.people + train_queue.quantity

          user_game.update!(update_params)
        end

        train_queue.destroy!
      end
    rescue StandardError => e
      @errors << e.message
    end
  end
end
