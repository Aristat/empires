# frozen_string_literal: true

module Trades
  class LocalBuyCommand < BaseCommand
    include ActionView::Helpers::NumberHelper

    attr_reader :user_game, :params, :calculate_local_trade_multiplier, :game_data, :buildings, :messages

    def initialize(user_game:, local_buy_params:)
      @user_game = user_game
      @params = local_buy_params
      @calculate_local_trade_multiplier = Trades::LocalTradeMultiplierCommand.new(user_game: user_game).call
      @game_data = PrepareGameDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @buildings = PrepareBuildingsDataCommand.new(civilization: user_game.civilization).call.with_indifferent_access
      @messages = []

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
        @errors << 'Cannot buy negative amounts.'
        return
      end

      if total_new_trades > trades_remaining
        @errors << "You can only trade #{number_with_delimiter(trades_remaining)} more goods this month."
        return
      end

      if need_gold > user_game.gold
        @errors << "You do not have enough gold to buy those goods (you need #{number_with_delimiter(need_gold)} gold)"
      end
    end

    def process_trade
      user_game.update!(
        wood: user_game.wood + buy_wood,
        food: user_game.food + buy_food,
        iron: user_game.iron + buy_iron,
        tools: user_game.tools + buy_tools,
        gold: user_game.gold - need_gold,
        trades_this_turn: user_game.trades_this_turn + total_new_trades
      )

      add_success_messages
    end

    def add_success_messages
      if buy_wood > 0
        @messages << ("#{number_with_delimiter(buy_wood)} wood bought for #{number_with_delimiter(buy_wood * wood_price)} gold.")
      end

      if buy_food > 0
        @messages << ("#{number_with_delimiter(buy_food)} food bought for #{number_with_delimiter(buy_food * food_price)} gold.")
      end

      if buy_iron > 0
        @messages << ("#{number_with_delimiter(buy_iron)} iron bought for #{number_with_delimiter(buy_iron * iron_price)} gold.")
      end

      if buy_tools > 0
        @messages << ("#{number_with_delimiter(buy_tools)} tools bought for #{number_with_delimiter(buy_tools * tool_price)} gold.")
      end

      @messages << ("You spent a total of #{number_with_delimiter(need_gold)} gold.")
    end

    def negative_amounts?
      buy_wood < 0 || buy_iron < 0 || buy_food < 0 || buy_tools < 0
    end

    def total_new_trades
      @total_new_trades ||= buy_wood + buy_iron + buy_food + buy_tools
    end

    def need_gold
      @need_gold ||= buy_wood * wood_price + buy_food * food_price + buy_iron * iron_price + buy_tools * tool_price
    end

    def trades_remaining
      @trades_remaining ||= max_trades - user_game.trades_this_turn
    end

    def max_trades
      @max_trades ||= Trades::MaxTradesCommand.new(user_game: user_game, buildings: buildings).call
    end

    def wood_price
      @wood_price ||= (game_data[:local_wood_buy_price] * calculate_local_trade_multiplier).round
    end

    def food_price
      @food_price ||= (game_data[:local_food_buy_price] * calculate_local_trade_multiplier).round
    end

    def iron_price
      @iron_price ||= (game_data[:local_iron_buy_price] * calculate_local_trade_multiplier).round
    end

    def tool_price
      @tool_price ||= (game_data[:local_tools_buy_price] * calculate_local_trade_multiplier).round
    end

    def buy_wood
      @buy_wood ||= params[:buy_wood].to_i
    end

    def buy_iron
      @buy_iron ||= params[:buy_iron].to_i
    end

    def buy_food
      @buy_food ||= params[:buy_food].to_i
    end

    def buy_tools
      @buy_tools ||= params[:buy_tools].to_i
    end
  end
end
