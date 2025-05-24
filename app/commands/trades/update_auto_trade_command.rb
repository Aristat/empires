# frozen_string_literal: true

module Trades
  class UpdateAutoTradeCommand < BaseCommand
    include ActionView::Helpers::NumberHelper

    attr_reader :user_game, :params, :game_data, :buildings, :messages

    def initialize(user_game:, update_auto_trade_params:)
      @user_game = user_game
      @params = update_auto_trade_params
      @game_data = PrepareGameDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @buildings = PrepareBuildingsDataCommand.new(civilization: user_game.civilization).call.with_indifferent_access
      @messages = []

      super()
    end

    def call
      validate_auto_trade
      return if failed?

      ActiveRecord::Base.transaction do
        process_auto_trade
      end
    rescue StandardError => e
      @errors << e.message
    end

    private

    def validate_auto_trade
      if negative_amounts?
        @errors << 'Cannot sell or buy negative numbers.'
        return
      end

      if total_trades > max_trades
        @errors << "You can only trade up to #{number_with_delimiter(max_trades)} goods each month."
      end
    end

    def process_auto_trade
      user_game.update!(
        auto_buy_wood: buy_wood,
        auto_sell_wood: sell_wood,
        auto_buy_iron: buy_iron,
        auto_sell_iron: sell_iron,
        auto_buy_food: buy_food,
        auto_sell_food: sell_food,
        auto_buy_tools: buy_tools,
        auto_sell_tools: sell_tools
      )
    end

    def negative_amounts?
      buy_wood < 0 || buy_iron < 0 || buy_food < 0 || buy_tools < 0 ||
        sell_wood < 0 || sell_iron < 0 || sell_food < 0 || sell_tools < 0
    end

    def total_trades
      @total_trades ||= buy_wood + buy_iron + buy_food + buy_tools +
                       sell_wood + sell_iron + sell_food + sell_tools
    end

    def max_trades
      @max_trades ||= Trades::CalculateMaxTradesCommand.new(user_game: user_game, buildings: buildings).call
    end

    def buy_wood
      @buy_wood ||= params[:auto_buy_wood].to_i
    end

    def buy_iron
      @buy_iron ||= params[:auto_buy_iron].to_i
    end

    def buy_food
      @buy_food ||= params[:auto_buy_food].to_i
    end

    def buy_tools
      @buy_tools ||= params[:auto_buy_tools].to_i
    end

    def sell_wood
      @sell_wood ||= params[:auto_sell_wood].to_i
    end

    def sell_iron
      @sell_iron ||= params[:auto_sell_iron].to_i
    end

    def sell_food
      @sell_food ||= params[:auto_sell_food].to_i
    end

    def sell_tools
      @sell_tools ||= params[:auto_sell_tools].to_i
    end
  end
end
