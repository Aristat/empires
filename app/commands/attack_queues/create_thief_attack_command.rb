# frozen_string_literal: true

module AttackQueues
  class CreateThiefAttackCommand < BaseCommand
    attr_reader :user_game, :params, :soldiers_data, :attack_type, :send_all, :send_thieves,
                :to_user_game, :gold_cost, :food_cost

    THIEF_ATTACK_TYPE = 20

    def initialize(user_game:, thief_attack_params:)
      @user_game = user_game
      @params = thief_attack_params
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
      extract_thieves
      calculate_costs
    end

    def extract_thieves
      soldiers_variants = [user_game.thieve_soldiers.to_i]
      soldiers_variants << params[:thieve].to_i unless send_all
      @send_thieves = soldiers_variants.min
    end

    def calculate_costs
      @gold_cost = (
        send_thieves * soldiers_data[:thieve][:settings][:gold_per_turn] * AttackQueue.attack_statuses.length
      ).round
      @food_cost = (
        send_thieves * soldiers_data[:thieve][:settings][:food_eaten] * AttackQueue.attack_statuses.length
      ).round
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
      elsif user_game.gold < gold_cost
        @errors << I18n.t('attacks.errors.not_enough_gold_thieves', needed: gold_cost)
      elsif user_game.food < food_cost
        @errors << I18n.t('attacks.errors.not_enough_food_thieves', needed: food_cost)
      elsif attack_type.blank? || !attack_type.in?(%w[thief_steal_army_information thief_steal_building_information thief_steal_research_information thief_steal_goods thief_poison_water thief_set_fire])
        @errors << I18n.t('attacks.errors.invalid_attack_type')
      elsif send_thieves <= 0
        @errors << I18n.t('attacks.errors.cannot_send_zero_thieves')
      elsif user_game.attack_queues.exists?(
        attack_type: %w[thief_steal_army_information thief_steal_building_information thief_steal_research_information thief_steal_goods thief_poison_water thief_set_fire]
      )
        @errors << I18n.t('attacks.errors.army_busy')
      elsif user_game.score > to_user_game.score * 2
        @errors << I18n.t('attacks.errors.target_too_small')
      elsif user_game.score * 2 < to_user_game.score
        @errors << I18n.t('attacks.errors.target_too_big')
      end
    end

    def create_attack_queue
      attack_queue = user_game.attack_queues.new(
        game: user_game.game,
        to_user_game: to_user_game,
        attack_status: :preparing,
        attack_type: attack_type,
        cost_gold: gold_cost,
        cost_food: food_cost,
        thieve_soldiers: send_thieves
      )

      attack_queue.save!

      messages << I18n.t('attacks.messages.thieves_preparing', email: to_user_game.user.email, id: to_user_game.id)
      messages << I18n.t('attacks.messages.reaching_destination')
      messages << I18n.t('attacks.messages.thieves_paid', gold: gold_cost, food: food_cost)
    end

    def update_user_game_resources
      user_game.thieve_soldiers -= send_thieves
      user_game.gold -= gold_cost
      user_game.food -= food_cost

      user_game.save!
    end
  end
end
