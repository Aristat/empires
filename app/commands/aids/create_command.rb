# frozen_string_literal: true

module Aids
  class CreateCommand < BaseCommand
    include ActionView::Helpers::NumberHelper

    AID_COOLDOWN_TIME = 4.hours.freeze

    attr_reader :user_game, :params, :game_data, :buildings, :to_user_game

    def initialize(user_game:, aid_params:)
      @user_game = user_game
      @params = aid_params
      @game_data = PrepareGameDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @buildings = PrepareBuildingsDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access

      super()
    end

    def call
      validate_aid
      return if failed?

      ActiveRecord::Base.transaction do
        process_aid
      end
    rescue StandardError => e
      @errors << e.message
    end

    private

    def validate_aid
      # Check if recipient exists
      to_user_game_id = params[:to_user_game_id].to_i
      @to_user_game = UserGame.find_by(id: to_user_game_id)

      if to_user_game.nil?
        @errors << "Empire ##{to_user_game_id} not found."
        return
      end

      recent_aid = TransferQueue.joins(:user_game)
                               .where(user_games: { user_id: user_game.user_id })
                               .where(to_user_game_id: to_user_game_id, transfer_type: :aid)
                               .exists?(['transfer_queues.created_at >= ?', AID_COOLDOWN_TIME.ago])

      if recent_aid
        @errors << 'You are only allowed to send aid to the same person once every 4 hours.'
        return
      end

      # Validate resource amounts
      total_send = 0
      UserGame::AID_RESOURCES.each do |resource|
        send_amount = params["send_#{resource}".to_sym].to_i
        current_amount = user_game.send(resource)

        if send_amount.negative?
          @errors << "Cannot send negative #{resource}."
        elsif send_amount > current_amount
          @errors << "You can only send #{number_with_delimiter(current_amount)} #{resource}."
        end

        total_send += send_amount
      end

      return if failed?

      max_trades = Trades::MaxTradesCommand.new(user_game: user_game, buildings: buildings).call
      trades_remaining = max_trades - user_game.trades_this_turn

      if total_send.zero?
        @errors << 'Cannot send 0 goods.'
      elsif total_send > trades_remaining
        @errors << "You can send only #{number_with_delimiter(trades_remaining)} more goods this month."
      end
    end

    def process_aid
      # Calculate totals and prepare updates
      params_for_user_game_update = {}
      params_for_transfer_queue = { to_user_game_id: to_user_game.id }
      total_send = 0

      UserGame::AID_RESOURCES.each do |resource|
        send_amount = params["send_#{resource}".to_sym].to_i
        next if send_amount.zero?

        # Deduct from sender
        params_for_user_game_update[resource] = user_game.send(resource) - send_amount

        # Apply 5% merchant fee
        after_fee_amount = (send_amount * 0.95).round
        params_for_transfer_queue[resource] = after_fee_amount

        total_send += send_amount
      end

      return if params_for_user_game_update.blank?

      # Update sender's resources and trade count
      params_for_user_game_update[:trades_this_turn] = user_game.trades_this_turn + total_send
      user_game.update!(params_for_user_game_update)

      # Create transfer queue entry
      params_for_transfer_queue = params_for_transfer_queue.merge(
        game_id: user_game.game_id,
        user_game: user_game,
        turns_remaining: 3,
        transfer_type: :aid
      )

      TransferQueue.create!(params_for_transfer_queue)

      @messages << "Transport to #{to_user_game.user.email} has been dispatched."
      @messages << '5% fee has been assessed by merchants.'
      @messages << 'Caravans will reach their destination in 3 turns.'
    end
  end
end
