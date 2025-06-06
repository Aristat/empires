# frozen_string_literal: true

module BuildQueues
  class CreateCommand < BaseCommand
    attr_reader :user_game, :params, :buildings

    def initialize(user_game:, build_queue_params:)
      @user_game = user_game
      @params = build_queue_params
      @buildings = PrepareBuildingsDataCommand.new(game: user_game.game, civilization: user_game.civilization).call.with_indifferent_access

      super()
    end

    def call
      if params[:building_queue_type] ==  BuildQueue.string_key(:queue_types, :build)
        build_queue
      elsif params[:building_queue_type] == BuildQueue.string_key(:queue_types, :demolish)
        demolish_queue
      end

      true
    rescue StandardError => e
      @errors << e.message
      false
    end

    private

    def build_queue
      return false unless validate_params
      return false unless validate_resources
      return false unless validate_land

      ActiveRecord::Base.transaction do
        create_build_queue
        update_resources
      end
    end

    def demolish_queue
      building = buildings[params[:building_type].to_sym]
      quantity = params[:building_quantity].to_i

      if quantity < 1 || quantity > BuildQueue::MAX_BUILDING_QUANTITY_PER_ACTION
        @errors << 'Cannot demolish 0 buildings.'
        return false
      end

      # Check how many are being destroyed
      total_demolishing = user_game.build_queues
        .where(building_type: params[:building_type], queue_type: BuildQueue.string_key(:queue_types, :demolish))
        .sum(:quantity)

      current_buildings = user_game.send(params[:building_type])
      available_buildings = current_buildings - total_demolishing

      if available_buildings < quantity
        @errors << 'You do not have that many buildings of this type.'
        return false
      end

      time_needed = (building[:settings][:cost_wood] + building[:settings][:cost_iron]) * quantity

      user_game.build_queues.create!(
        building_type: params[:building_type],
        queue_type: :demolish,
        quantity: quantity,
        turn_added: user_game.turn,
        time_needed: time_needed,
        position: 1,
      )
    end

    def validate_params
      if params[:building_type].blank? || !buildings.key?(params[:building_type].to_sym)
        @errors << 'Invalid building to build.'
        return false
      end

      if params[:building_quantity].to_i <= 0 ||
        params[:building_quantity].to_i > BuildQueue::MAX_BUILDING_QUANTITY_PER_ACTION
        @errors << 'Invalid number of buildings.'
        return false
      end

      true
    end

    def validate_resources
      building = buildings[params[:building_type].to_sym]
      quantity = params[:building_quantity].to_i

      @needed_gold = building[:settings][:cost_gold] * quantity
      @needed_wood = building[:settings][:cost_wood] * quantity
      @needed_iron = building[:settings][:cost_iron] * quantity

      if @needed_gold > user_game.gold
        @errors << "You do not have enough gold.\nYou need #{@needed_gold}"
        return false
      end

      if @needed_wood > user_game.wood
        @errors << "You do not have enough wood.\nYou need #{@needed_wood}"
        return false
      end

      if @needed_iron > user_game.iron
        @errors << "You do not have enough iron.\nYou need #{@needed_iron}"
        return false
      end

      true
    end

    def validate_land
      building = buildings[params[:building_type].to_sym]
      quantity = params[:building_quantity].to_i
      needed_land = quantity * building[:settings][:squares]

      case building[:settings][:land]
      when 'mountain'
        available_land = user_game.m_land - calculate_used_land('mountain')
      when 'forest'
        available_land = user_game.f_land - calculate_used_land('forest')
      when 'plain'
        available_land = user_game.p_land - calculate_used_land('plain')
      end

      if needed_land > available_land
        @errors << "You do not have that much free land. (needed #{needed_land})"
        return false
      end

      true
    end

    def calculate_used_land(land_type)
      used_land = 0
      buildings.each do |key, building|
        next unless building[:settings][:land] == land_type

        used_land += user_game.send(key) * building[:settings][:squares]
      end
      used_land
    end

    def create_build_queue
      time_needed = @needed_wood + @needed_iron

      @build_queue = @user_game.build_queues.create!(
        building_type: params[:building_type],
        quantity: params[:building_quantity].to_i,
        queue_type: params[:building_queue_type],
        turn_added: user_game.turn,
        time_needed: time_needed,
        position: 1,
        iron: @needed_iron,
        wood: @needed_wood,
        gold: @needed_gold
      )
    end

    def update_resources
      @user_game.update!(
        gold: @user_game.gold - @needed_gold,
        iron: @user_game.iron - @needed_iron,
        wood: @user_game.wood - @needed_wood
      )
    end
  end
end
