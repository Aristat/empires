# frozen_string_literal: true

module Trades
  class GlobalBuyCommand < BaseCommand
    include ActionView::Helpers::NumberHelper

    attr_reader :user_game, :resource, :game_data, :quantities

    def initialize(user_game:, resource:, quantities:)
      @user_game = user_game
      @resource = resource
      @game_data = PrepareGameDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @quantities = quantities

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

          remaining_resources = 0
          TransferQueue::RESOURCES.each do |resource_column|
            next if transfer_queue.send(resource_column).blank?

            remaining_resources += user_game.send(resource_column)
          end
          remaining_resources -= quantity

          if remaining_resources > 0
            transfer_queue.update!("#{resource}" => transfer_queue.public_send(resource) - quantity)
          else
            transfer_queue.destroy!
          end

          seller_gold = (cost * (1 - game_data[:global_fee_percent].to_f / 100)).round
          seller = transfer_queue.user_game
          seller.update!(gold: seller.gold + seller_gold)

          TransferQueue.create!(
            user_game_id: seller.id,
            to_user_game_id: user_game.id,
            game_id: user_game.game_id,
            transfer_type: :buy,
            turns_remaining: TransferQueue::DEFAULT_TURNS_REMAINING,
            "#{resource}" => quantity
          )
        end
      end
    rescue StandardError => e
      @errors << e.message
    end
  end
end
