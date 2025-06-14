# frozen_string_literal: true

module Trades
  class GlobalMarketDataCommand < BaseCommand
    DEFAULT_MAX_TRADES = 50

    attr_reader :user_game, :resource

    def initialize(user_game:, resource:)
      @user_game = user_game
      @resource = resource
    end

    def call
      resource_column = resource.to_s
      resource_price_column = "#{resource_column}_price"

      raise NotImplemented unless TransferQueue.column_names.include?(resource_column)

      listings = TransferQueue
                   .select(
                     :id,
                     "#{resource_column} AS available",
                     "#{resource_price_column} AS price",
                     :user_game_id
                   )
                   .preload(user_game: :user)
                   .where(game_id: @user_game.game_id, turns_remaining: 0)
                   .where("#{resource_price_column} > 0")
                   .where("#{resource_column} > 0")
                   .order("#{resource_price_column} ASC, #{resource_column} DESC")
                   .limit(10)
                   .map do |listing|
        {
          id: listing.id,
          available: listing['available'],
          price: listing['price'],
          user_game_id: listing.user_game_id,
          name: listing.user_game.user.name || listing.user_game.user.email
        }
      end

      listings
    end
  end
end
