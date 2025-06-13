# frozen_string_literal: true

module Trades
  class GlobalBuyCommand < BaseCommand
    include ActionView::Helpers::NumberHelper

    attr_reader :user_game, :resource, :quantities, :messages

    def initialize(user_game:, resource:, quantities:)
      @user_game = user_game
      @resource = resource
      @quantities = quantities
      @messages = []

      super()
    end

    def call
      return if failed?
      raise NotImplemented unless UserGame::GLOBAL_TRADE_RESOURCES.include?(resource)

      available_gold = user_game.gold
      resource_price_column = "#{resource}_price"

      transfer_queues_ids = []
      quantities.each do |transfer_queue_id, quantity|
        quantity = quantity.to_i
        next if transfer_queue_id.blank? || quantity <= 0

        transfer_queues_ids << transfer_queue_id
      end

      transfer_queues = TransferQueue.
        where(id: transfer_queues_ids, game_id: user_game.game_id, transfer_type: :sell).
        where.not(user_game_id: user_game.id).
        where('turns_remaining = 0').
        where("#{resource} > 0").
        index_by(&:id)

      ActiveRecord::Base.transaction do
        quantities.each do |transfer_queue_id, quantity|
          quantity = quantity.to_i
          next if quantity <= 0

          transfer_queue = transfer_queues[transfer_queue_id.to_i]
          next unless transfer_queue

          # Check if sufficient resources are available
          if quantity > transfer_queue.public_send(resource)
            @errors << "You tried to buy #{quantity} #{resource}, but there are only #{transfer_queue.public_send(resource)} available."
            break
          end

          # Check if user has enough gold
          price = transfer_queue.public_send(resource_price_column)
          cost = quantity * price

          if cost > available_gold
            @errors << "You do not have enough gold to buy #{quantity} #{resource}. You need #{cost} gold."
            break
          end

          # Update buyer's gold
          user_game.update!(gold: user_game.gold - cost)
          available_gold -= cost

          @messages << "#{number_with_delimiter(quantity)} #{resource} bought for #{number_with_delimiter(cost)}. The caravans with #{resource} will reach your empire in 3 months."

          # Update or delete the transfer queue based on remaining resources
          remaining_resources = transfer_queue.wood.to_i + 
                               transfer_queue.iron.to_i + 
                               transfer_queue.food.to_i + 
                               transfer_queue.tools.to_i + 
                               transfer_queue.maces.to_i + 
                               transfer_queue.swords.to_i + 
                               transfer_queue.bows.to_i + 
                               transfer_queue.horses.to_i - 
                               quantity

          if remaining_resources > 0
            transfer_queue.update!("#{resource}" => transfer_queue.public_send(resource) - quantity)
          else
            transfer_queue.destroy!
          end

          # Give gold to the seller (5% market fee)
          seller_gold = (cost * 0.95).round
          seller = transfer_queue.user_game
          seller.update!(gold: seller.gold + seller_gold)

          TransferQueue.create!(
            user_game_id: seller.id,
            to_user_game_id: user_game.id,
            game_id: user_game.game_id,
            transfer_type: :buy,
            turns_remaining: 3,
            "#{resource}" => quantity
          )
        end
      end
    rescue StandardError => e
      @errors << e.message
    end
  end
end
