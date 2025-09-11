# frozen_string_literal: true

module Trades
  class GlobalSellCommand < BaseCommand
    include ActionView::Helpers::NumberHelper

    attr_reader :user_game, :params, :game_data, :buildings

    def initialize(user_game:, global_sell_params:)
      @user_game = user_game
      @params = global_sell_params
      @game_data = PrepareGameDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @buildings = PrepareBuildingsDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access

      super()
    end

    def call
      validate_trade
      return if failed?

      ActiveRecord::Base.transaction do
        process_trade
      end
    rescue StandardError => e
      @errors << e.message
    end

    private

    def validate_trade
      UserGame::GLOBAL_TRADE_RESOURCES.each do |resource|
        next if params["sell_#{resource}"].blank? || params["price_#{resource}"].blank?

        sell_amount = params["sell_#{resource}"].to_i
        sell_price = params["price_#{resource}"].to_i
        min_price = game_data["global_#{resource}_min_price"]
        max_price = game_data["global_#{resource}_max_price"]
        current_amount = user_game.send(resource)

        if sell_amount.negative?
          @errors << "Cannot sell negative #{resource}."
        elsif sell_amount.positive? && sell_amount > current_amount
          @errors << "You don't have that many #{resource}. You only have #{number_with_delimiter(current_amount)}."
        elsif sell_amount.positive? && sell_price < min_price
          @errors << "The minimum sell price for #{resource} is #{number_with_delimiter(min_price)} gold."
        elsif sell_amount.positive? && sell_price > max_price
          @errors << "The maximum sell price for #{resource} is #{number_with_delimiter(max_price)} gold."
        end
      end

      return if failed?

      total_sell = UserGame::GLOBAL_TRADE_RESOURCES.sum { |r| params["sell_#{r}"].to_i }
      max_trades = Trades::MaxTradesCommand.new(user_game: user_game, buildings: buildings).call
      trades_remaining = max_trades - user_game.trades_this_turn

      if total_sell.zero?
        @errors << 'Cannot sell 0 goods.'
      elsif total_sell > trades_remaining
        @errors << "You can sell only #{number_with_delimiter(trades_remaining)} more goods this month."
      end
    end

    def process_trade
      params_for_user_game_update = {}
      params_for_transfer_queue = {}
      total_sell = 0
      total_price = 0
      UserGame::GLOBAL_TRADE_RESOURCES.each do |resource|
        next if params["sell_#{resource}"].blank? || params["price_#{resource}"].blank?

        sell_resource = params["sell_#{resource}"].to_i
        price_resource = params["price_#{resource}"].to_i
        params_for_user_game_update[resource] = user_game.send(resource) - sell_resource
        params_for_transfer_queue[resource] = sell_resource
        params_for_transfer_queue["#{resource}_price"] = price_resource
        total_sell += sell_resource
        total_price += sell_resource * price_resource
      end

      if params_for_user_game_update.blank?
        @errors << 'Cannot sell 0 goods.'
        return
      end

      params_for_user_game_update[:trades_this_turn] = user_game.trades_this_turn + total_sell
      user_game.update!(params_for_user_game_update)

      params_for_transfer_queue = params_for_transfer_queue.merge(
        {
          game_id: user_game.game_id,
          user_game: user_game,
          turns_remaining: TransferQueue::DEFAULT_TURNS_REMAINING,
          transfer_type: :sell
        }
      )

      TransferQueue.create!(params_for_transfer_queue)

      @messages << 'Goods have been sent to the public market. They will reach the market in 3 months.'
      @messages << "Total value of the transport is #{number_with_delimiter(total_price)}."
    end
  end
end
