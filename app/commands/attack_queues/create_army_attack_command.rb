# frozen_string_literal: true

module AttackQueues
  class CreateArmyAttackCommand < BaseCommand
    attr_reader :user_game, :params, :attack_type, :send_all, :maximum_wine, :total_army, :soldiers_data,
                :soldiers_to_attack, :to_user_game, :food_cost, :gold_cost, :wine_cost

    def initialize(user_game:, army_attack_params:)
      @user_game = user_game
      @params = army_attack_params
      @soldiers_data = PrepareSoldiersDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access

      @send_all = ActiveRecord::Type::Boolean.new.cast(params[:send_all])
      @maximum_wine = ActiveRecord::Type::Boolean.new.cast(params[:maximum_wine])
      @attack_type = params[:attack_type]
      @total_army = 0
      @soldiers_to_attack = {}
      
      @food_cost = 0
      @gold_cost = 0
      @wine_cost = 0

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
      extract_soldiers
      calculate_costs
    end

    def extract_soldiers
      @soldiers_to_attack = {}

      UserGame::SOLDIERS.keys.each do |soldier_key|
        next if soldiers_data[soldier_key][:settings][:soldier_type] != 'unit'

        soldiers_variants = [user_game.send("#{soldier_key}_soldiers").to_i]
        soldiers_variants << params[soldier_key].to_i unless send_all
        soldiers = soldiers_variants.min
        next if soldiers <= 0

        @soldiers_to_attack[soldier_key] = soldiers
      end

      @total_army = soldiers_to_attack.values.sum
      @wine_cost = maximum_wine ? [user_game.wine, total_army].min : [user_game.wine, params[:cost_wine].to_i].min
    end

    def calculate_costs
      @food_cost = calculate_food_cost
      @gold_cost = calculate_gold_cost
    end

    def calculate_food_cost
      soldiers_to_attack.each do |soldier_key, count|
        next if soldiers_data[soldier_key].blank?

        @food_cost += count * soldiers_data[soldier_key][:settings][:food_eaten]
      end

      (food_cost * AttackQueue.attack_statuses.length).round
    end

    def calculate_gold_cost
      soldiers_to_attack.each do |soldier_key, count|
        next if soldiers_data[soldier_key].blank?
        
        @gold_cost += count * soldiers_data[soldier_key][:settings][:gold_per_turn]
      end

      (gold_cost * AttackQueue.attack_statuses.length).round
    end

    def find_to_user_game
      @to_user_game = user_game.game.user_games.find_by(id: params[:to_user_game_id])

      @errors << 'Target empire does not exist' unless to_user_game
    end

    def validate_attack
      if to_user_game.id == user_game.id
        @errors << 'You cannot attack yourself'
      elsif user_game.food < food_cost
        @errors << "You do not have enough food to send your soldiers. You need #{food_cost} to send that much army."
      elsif attack_type.blank? || !attack_type.in?(%w[army_conquer army_raid army_rob army_slaughter])
        @errors << 'Invalid attack type'
      elsif soldiers_to_attack.any? { |_, count| count < 0 }
        @errors << 'Cannot send negative soldiers'
      elsif total_army <= 0
        @errors << 'Cannot send 0 total army'
      elsif wine_cost < 0
        @errors << 'Cannot send negative wine'
      elsif wine_cost > total_army
        @errors << 'You can only send 1 wine per soldier'
      elsif wine_cost > user_game.wine
        @errors << 'You do not have that much wine'
      elsif user_game.attack_queues.exists?(attack_type: %w[army_conquer army_raid army_rob army_slaughter])
        @errors << 'Your armies are already attacking someone. Please wait for them to come back.'
      elsif user_game.gold < gold_cost
        @errors << "You do not have enough gold to pay your soldiers to fight (You need #{gold_cost} gold)"
      end
    end

    def create_attack_queue
      attack_queue = user_game.attack_queues.new(
        game: user_game.game,
        to_user_game: to_user_game,
        attack_status: :preparing,
        attack_type: attack_type,
        cost_food: food_cost,
        cost_gold: gold_cost,
        cost_wine: wine_cost
      )

      soldiers_to_attack.each do |soldier_type, count|
        attack_queue.send("#{soldier_type}_soldiers=", count)
      end

      attack_queue.save!

      message = "Your army is preparing to attack #{to_user_game.user.email} (#{to_user_game.id}). They will reach their destination in 3 months. Your soldiers have been paid #{gold_cost} and given #{food_cost} food for this expedition."
      if wine_cost > 0
        percent_wine = ((wine_cost.to_f / total_army) * 100.0).round
        message += " #{wine_cost} units of wine will boost army strength by #{percent_wine}"
      end

      messages << message
    end

    def update_user_game_resources
      soldiers_to_attack.each do |soldier_type, count|
        user_game.send("#{soldier_type}_soldiers=", user_game.send("#{soldier_type}_soldiers") - count)
      end

      user_game.gold -= gold_cost
      user_game.food -= food_cost
      user_game.wine -= wine_cost

      user_game.save!
    end
  end
end
