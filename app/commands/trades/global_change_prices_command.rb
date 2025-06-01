# frozen_string_literal: true

module Trades
  class GlobalChangePricesCommand < BaseCommand
    include ActionView::Helpers::NumberHelper

    attr_reader :user_game, :transfer_queue, :params, :game_data, :messages

    def initialize(user_game:, transfer_queue:, global_change_prices_params:)
      @user_game = user_game
      @transfer_queue = transfer_queue
      @params = global_change_prices_params
      @game_data = PrepareGameDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @messages = []

      super()
    end

    def call
      validate_prices
      return if failed?

      ActiveRecord::Base.transaction do
        process_price_changes
      end
    rescue StandardError => e
      @errors << e.message
    end

    private

    def validate_prices
      UserGame::GLOBAL_TRADE_RESOURCES.each do |resource|
        next if params["price_#{resource}"].blank?

        new_price = params["price_#{resource}"].to_i
        min_price = game_data["global_#{resource}_min_price"]
        max_price = game_data["global_#{resource}_max_price"]

        if new_price.positive? && new_price < min_price
          @errors << "Cannot change price for #{resource} to #{number_with_delimiter(new_price)}. " \
            "Minimum sell price is #{number_with_delimiter(min_price)}."
        elsif new_price.positive? && new_price > max_price
          @errors << "Cannot change price for #{resource} to #{number_with_delimiter(new_price)}. " \
            "Maximum sell price is #{number_with_delimiter(max_price)}."
        end
      end
    end

    def process_price_changes
      price_changes = {}
      UserGame::GLOBAL_TRADE_RESOURCES.each do |resource|
        next if params["price_#{resource}"].blank?

        new_price = params["price_#{resource}"].to_i
        current_price = transfer_queue.send("#{resource}_price")

        if new_price != current_price
          price_changes["#{resource}_price"] = new_price
          @messages << "Changed price for #{resource} to #{number_with_delimiter(new_price)}"
        end
      end

      return if price_changes.empty?

      transfer_queue.update!(price_changes)
    end
  end
end
