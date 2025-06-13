# frozen_string_literal: true

module Trades
  class GlobalWithdrawCommand < BaseCommand
    include ActionView::Helpers::NumberHelper

    attr_reader :user_game, :transfer_queue, :messages

    def initialize(user_game:, transfer_queue:)
      @user_game = user_game
      @transfer_queue = transfer_queue
      @messages = []

      super()
    end

    def call
      return if failed?

      update_params = {}

      update_params[:wood] = user_game.wood + (transfer_queue.wood * 0.9).round if transfer_queue.wood.present?
      update_params[:iron] = user_game.iron + (transfer_queue.iron * 0.9).round if transfer_queue.iron.present?
      update_params[:food] = user_game.food + (transfer_queue.food * 0.9).round if transfer_queue.food.present?
      update_params[:tools] = user_game.tools + (transfer_queue.tools * 0.9).round if transfer_queue.tools.present?
      update_params[:swords] = user_game.swords + (transfer_queue.swords * 0.9).round if transfer_queue.swords.present?
      update_params[:bows] = user_game.bows + (transfer_queue.bows * 0.9).round if transfer_queue.bows.present?
      update_params[:horses] = user_game.horses + (transfer_queue.horses * 0.9).round if transfer_queue.horses.present?
      update_params[:maces] = user_game.maces + (transfer_queue.maces * 0.9).round if transfer_queue.maces.present?

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
