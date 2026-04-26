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

      ActiveRecord::Base.transaction do
        create_attack_queue
        update_user_game_resources
      end
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

      @errors << I18n.t('attacks.errors.target_not_found') unless to_user_game
    end

    def validate_attack
      if to_user_game.protection_turns > 0
        @errors << I18n.t('attacks.errors.target_under_protection', email: to_user_game.user.email, turns: to_user_game.protection_turns)
      elsif to_user_game.id == user_game.id
        @errors << I18n.t('attacks.errors.cannot_attack_self')
      elsif user_game.wood < wood_cost
        @errors << I18n.t('attacks.errors.not_enough_wood_catapult', needed: wood_cost)
      elsif user_game.iron < iron_cost
        @errors << I18n.t('attacks.errors.not_enough_iron_catapult', needed: iron_cost)
      elsif attack_type.blank? || !attack_type.in?(%w[catapult_army_and_towers catapult_population catapult_buildings])
        @errors << I18n.t('attacks.errors.invalid_attack_type')
      elsif send_catapults <= 0
        @errors << I18n.t('attacks.errors.cannot_send_zero_catapults')
      elsif user_game.attack_queues.exists?(
        attack_type: %w[catapult_army_and_towers catapult_population catapult_buildings]
      )
        @errors << I18n.t('attacks.errors.army_busy')
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

      messages << I18n.t('attacks.messages.catapults_preparing', email: to_user_game.user.email, id: to_user_game.id)
      messages << I18n.t('attacks.messages.reaching_destination')
      messages << I18n.t('attacks.messages.catapult_resources', wood: wood_cost, iron: iron_cost)
    end

    def update_user_game_resources
      user_game.catapult_soldiers -= send_catapults
      user_game.wood -= wood_cost
      user_game.iron -= iron_cost

      user_game.save!
    end
  end
end
