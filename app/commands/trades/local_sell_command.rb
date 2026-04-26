# frozen_string_literal: true

module Trades
  class LocalSellCommand < BaseCommand
    include ActionView::Helpers::NumberHelper

    attr_reader :user_game, :params, :calculate_local_trade_multiplier, :game_data, :buildings

    def initialize(user_game:, local_sell_params:)
      @user_game = user_game
      @params = local_sell_params
      @calculate_local_trade_multiplier = Trades::LocalTradeMultiplierCommand.new(user_game: user_game).call
      @game_data = PrepareGameDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @buildings = PrepareBuildingsDataCommand.new(game: user_game.game, civilization: user_game.civilization).call.with_indifferent_access

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
      if negative_amounts?
        @errors << I18n.t('trades.errors.cannot_sell_negative')
        return
      end

      if total_new_trades > trades_remaining
        @errors << I18n.t('trades.errors.trade_limit_turn', remaining: number_with_delimiter(trades_remaining))
        return
      end

      if sell_wood > user_game.wood
        @errors << I18n.t('trades.errors.not_enough_wood_sell')
        return
      end

      if sell_food > user_game.food
        @errors << I18n.t('trades.errors.not_enough_food_sell')
        return
      end

      if sell_iron > user_game.iron
        @errors << I18n.t('trades.errors.not_enough_iron_sell')
        return
      end

      if sell_tools > user_game.tools
        @errors << I18n.t('trades.errors.not_enough_tools_sell')
      end
    end

    def process_trade
      user_game.update!(
        wood: user_game.wood - sell_wood,
        food: user_game.food - sell_food,
        iron: user_game.iron - sell_iron,
        tools: user_game.tools - sell_tools,
        gold: user_game.gold + get_gold,
        trades_this_turn: user_game.trades_this_turn + total_new_trades
      )

      add_success_messages
    end

    def add_success_messages
      if sell_wood > 0
        @messages << I18n.t('trades.messages.resource_sold', quantity: number_with_delimiter(sell_wood), resource: 'wood', gold: number_with_delimiter(sell_wood * wood_price))
      end

      if sell_food > 0
        @messages << I18n.t('trades.messages.resource_sold', quantity: number_with_delimiter(sell_food), resource: 'food', gold: number_with_delimiter(sell_food * food_price))
      end

      if sell_iron > 0
        @messages << I18n.t('trades.messages.resource_sold', quantity: number_with_delimiter(sell_iron), resource: 'iron', gold: number_with_delimiter(sell_iron * iron_price))
      end

      if sell_tools > 0
        @messages << I18n.t('trades.messages.resource_sold', quantity: number_with_delimiter(sell_tools), resource: 'tools', gold: number_with_delimiter(sell_tools * tool_price))
      end

      @messages << I18n.t('trades.messages.total_earned', gold: number_with_delimiter(get_gold))
    end

    def negative_amounts?
      sell_wood < 0 || sell_iron < 0 || sell_food < 0 || sell_tools < 0
    end

    def total_new_trades
      @total_new_trades ||= sell_wood + sell_iron + sell_food + sell_tools
    end

    def get_gold
      @get_gold ||= sell_wood * wood_price + sell_food * food_price + sell_iron * iron_price + sell_tools * tool_price
    end

    def trades_remaining
      @trades_remaining ||= max_trades - user_game.trades_this_turn
    end

    def max_trades
      @max_trades ||= Trades::MaxTradesCommand.new(user_game: user_game, buildings: buildings).call
    end

    def wood_price
      @wood_price ||= (game_data[:local_wood_sell_price] * (1.0 / calculate_local_trade_multiplier)).round
    end

    def food_price
      @food_price ||= (game_data[:local_food_sell_price] * (1.0 / calculate_local_trade_multiplier)).round
    end

    def iron_price
      @iron_price ||= (game_data[:local_iron_sell_price] * (1.0 / calculate_local_trade_multiplier)).round
    end

    def tool_price
      @tool_price ||= (game_data[:local_tools_sell_price] * (1.0 / calculate_local_trade_multiplier)).round
    end

    def sell_wood
      @sell_wood ||= params[:sell_wood].to_i
    end

    def sell_iron
      @sell_iron ||= params[:sell_iron].to_i
    end

    def sell_food
      @sell_food ||= params[:sell_food].to_i
    end

    def sell_tools
      @sell_tools ||= params[:sell_tools].to_i
    end
  end
end
