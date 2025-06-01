# frozen_string_literal: true

module TrainQueues
  class CreateCommand < BaseCommand
    include ActionView::Helpers::NumberHelper

    attr_reader :user_game, :params, :game_data, :buildings, :soldiers, :total_quantity, :need_gold, :need_wood,
                :need_iron, :need_swords, :need_bows, :need_maces, :need_horses

    def initialize(user_game:, train_queue_params:)
      @user_game = user_game
      @params = train_queue_params
      @game_data = PrepareGameDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @buildings = PrepareBuildingsDataCommand.new(game: user_game.game, civilization: user_game.civilization).call.with_indifferent_access
      @soldiers = PrepareSoldiersDataCommand.new(game: user_game.game, civilization: user_game.civilization).call.with_indifferent_access

      @total_quantity = 0
      @need_gold = 0
      @need_wood = 0
      @need_iron = 0
      @need_swords = 0
      @need_bows = 0
      @need_maces = 0
      @need_horses = 0

      super()
    end

    def call
      return if params.blank?

      validate!
      return if failed?

      ActiveRecord::Base.transaction do
        create_train_queues
        update_resources
      end

      true
    end

    private

    def validate!
      return if params.blank?

      total_quantity = params.values.sum(&:to_i)
      return if total_quantity.zero?

      total_soldiers_limit_for_train = TrainQueues::LimitForTrainCommand.new(
        user_game: user_game, buildings: buildings
      ).call
      current_training = user_game.train_queues.sum(:quantity)
      new_training = current_training + total_quantity

      if new_training > total_soldiers_limit_for_train
        @errors << "You can only train #{number_with_delimiter(total_soldiers_limit_for_train)} soldiers."
        return true
      end

      if user_game.people < total_quantity
        @errors << 'You do not have enough people.'
        return true
      end

      params.each do |soldier_key, quantity|
        quantity = quantity.to_i
        soldier = soldiers[soldier_key]
        next if soldier.blank? || quantity <= 0
        next if soldier[:settings][:turns].negative?

        @total_quantity += quantity

        unless soldier[:settings][:train_gold].zero?
          @need_gold += soldier[:settings][:train_gold] * quantity
        end

        unless soldier[:settings][:train_wood].zero?
          @need_wood += soldier[:settings][:train_wood] * quantity
        end

        unless soldier[:settings][:train_iron].zero?
          @need_iron += soldier[:settings][:train_iron] * quantity
        end

        unless soldier[:settings][:train_swords].zero?
          @need_swords += soldier[:settings][:train_swords] * quantity
        end

        unless soldier[:settings][:train_bows].zero?
          @need_bows += soldier[:settings][:train_bows] * quantity
        end

        unless soldier[:settings][:train_maces].zero?
          @need_maces += soldier[:settings][:train_maces] * quantity
        end

        unless soldier[:settings][:train_horses].zero?
          @need_horses += soldier[:settings][:train_horses] * quantity
        end
      end

      if user_game.gold < need_gold
        @errors << 'You do not have enough gold for training.'
        return true
      end

      if user_game.wood < need_wood
        @errors << 'You do not have enough wood for training.'
        return
      end

      if user_game.iron < need_iron
        @errors << 'You do not have enough iron for training.'
        return true
      end

      if user_game.bows < need_bows
        @errors << 'You do not have enough bows for training.'
        return
      end

      if user_game.swords < need_swords
        @errors << 'You do not have enough swords for training.'
        return
      end

      if user_game.maces < need_maces
        @errors << 'You do not have enough horses for training.'
        return
      end

      if user_game.horses < need_horses
        @errors << 'You do not have enough horses for training.'
      end
    end

    def create_train_queues
      params.each do |soldier_key, quantity|
        quantity = quantity.to_i
        soldier = soldiers[soldier_key]
        next if soldier.blank? || quantity <= 0
        next if soldier[:settings][:turns].negative?

        user_game.train_queues.create!(
          soldier_key: soldier_key,
          quantity: quantity.to_i,
          turns_remaining: soldier[:settings][:turns]
        )
      end
    end

    def update_resources
      user_game.update!(
        swords: user_game.swords - need_swords,
        bows: user_game.bows - need_bows,
        maces: user_game.maces - need_maces,
        horses: user_game.horses - need_horses,
        wood: user_game.wood - need_wood,
        iron: user_game.iron - need_iron,
        gold: user_game.gold - need_gold,
        people: user_game.people - total_quantity
      )
    end
  end
end
