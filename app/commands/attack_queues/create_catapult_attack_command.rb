# frozen_string_literal: true

module AttackQueues
  class CreateCatapultAttackCommand < BaseCommand
    attr_reader :user_game, :params, :soldiers_data, :attack_type, :send_all, :send_catapults,
                :to_user_game, :wood_cost, :iron_cost

    def initialize(user_game:, catapult_attack_params:)
      @user_game = user_game
      @params = catapult_attack_params
      @soldiers_data = PrepareSoldiersDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @attack_type = params[:attack_type]
      @send_all = ActiveRecord::Type::Boolean.new.cast(params[:send_all])

      super()
    end

    def call
      find_to_user_game
      return if failed?

      extract_params
      validate_attack
      return if failed?

      create_attack_queue
      update_user_game_resources
    end

    private

    def extract_params
      extract_catapults
      calculate_costs
    end

    def extract_catapults
      soldiers_variants = [user_game.catapult_soldiers.to_i]
      soldiers_variants << params[:catapult].to_i unless send_all
      @send_catapults = soldiers_variants.min
    end

    def calculate_costs
      @wood_cost = (send_catapults * soldiers_data[:catapult][:settings][:wood_eaten]).round
      @iron_cost = (send_catapults * soldiers_data[:catapult][:settings][:iron_eaten]).round
    end

    def find_to_user_game
      @to_user_game = user_game.game.user_games.find_by(id: params[:to_user_game_id])

      @errors << 'Target empire does not exist' unless to_user_game
    end

    def validate_attack
      if to_user_game.id == user_game.id
        @errors << 'You cannot attack yourself'
      elsif user_game.wood < wood_cost
        @errors << "You do not have enough wood to send your catapults. You need #{wood_cost} to send that much army."
      elsif user_game.iron < iron_cost
        @errors << "You do not have enough iron to send your catapults. You need #{iron_cost} to send that much army."
      elsif attack_type.blank? || !attack_type.in?(%w[catapult_army_and_towers catapult_population catapult_buildings])
        @errors << 'Invalid attack type'
      elsif send_catapults <= 0
        @errors << 'Cannot send 0 total catapults'
      elsif user_game.attack_queues.exists?(
        attack_type: %w[catapult_army_and_towers catapult_population catapult_buildings]
      )
        @errors << 'Your armies are already attacking someone. Please wait for them to come back.'
      end
    end

    def create_attack_queue
      attack_queue = user_game.attack_queues.new(
        game: user_game.game,
        to_user_game: to_user_game,
        attack_status: :preparing,
        attack_type: attack_type,
        cost_wood: wood_cost,
        cost_iron: iron_cost,
        catapult_soldiers: send_catapults
      )

      attack_queue.save!

      messages << "Your catapults are preparing to attack #{to_user_game.user.email} (#{to_user_game.id})."
      messages << 'They will reach their destination in 3 months.'
      messages << "#{wood_cost} wood and #{iron_cost} iron has been sent for upkeep."
    end

    def update_user_game_resources
      user_game.catapult_soldiers -= send_catapults
      user_game.wood -= wood_cost
      user_game.iron -= iron_cost

      user_game.save!
    end
  end
end
