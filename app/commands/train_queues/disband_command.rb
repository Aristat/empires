# frozen_string_literal: true

module TrainQueues
  class DisbandCommand < BaseCommand
    attr_reader :user_game, :train_queue, :soldiers

    def initialize(user_game:, train_queue_params:)
      @user_game = user_game
      @params = train_queue_params
      @game_data = PrepareGameDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @buildings = PrepareBuildingsDataCommand.new(civilization: user_game.civilization).call.with_indifferent_access
      @soldiers = PrepareSoldiersDataCommand.new(civilization: user_game.civilization).call.with_indifferent_access

      super()
    end

    def call
      validate!
      return if failed?

      update_params = {}
      params.each do |soldier_key, quantity|
        quantity = quantity.to_i
        soldier = soldiers[soldier_key]
        next if soldier.blank? || quantity <= 0
        next unless user_game.respond_to?("#{soldier_key}_soldiers")

        if user_game.send("#{soldier_key}_soldiers") < quantity
          @errors << "Not enough #{soldier[:name]} soldiers to disband."
          next
        end

        unless soldier[:settings][:train_wood].zero?
          update_params[:wood] ||= user_game.wood
          update_params[:wood] += soldier[:settings][:train_wood] * train_queue.quantity
        end

        unless soldier[:settings][:train_iron].zero?
          update_params[:wood] ||= user_game.iron
          update_params[:iron] += soldier[:settings][:train_iron] * train_queue.quantity
        end

        unless soldier[:settings][:train_swords].zero?
          update_params[:wood] ||= user_game.swords
          update_params[:swords] += soldier[:settings][:train_swords] * train_queue.quantity
        end

        unless soldier[:settings][:train_bows].zero?
          update_params[:wood] ||= user_game.bows
          update_params[:bows] += soldier[:settings][:train_bows] * train_queue.quantity
        end

        unless soldier[:settings][:train_maces].zero?
          update_params[:wood] ||= user_game.maces
          update_params[:maces] += soldier[:settings][:train_maces] * train_queue.quantity
        end

        unless soldier[:settings][:train_horses].zero?
          update_params[:wood] ||= user_game.horses
          update_params[:horses] += soldier[:settings][:train_horses] * train_queue.quantity
        end

        # We get only 50% of resources back when disbanding soldiers
        update_params = update_params.each_with_object({}) do |(key, value), result|
          result[key] = value / 2
        end

        update_params[:people] ||= user_game.people
        update_params[:people] += quantity
        update_params["#{soldier_key}_soldiers"] = user_game.send("#{soldier_key}_soldiers") - quantity
      end

      user_game.update!(update_params) if update_params.present?
    rescue StandardError => e
      @errors << e.message
    end
  end
end
