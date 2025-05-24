# frozen_string_literal: true

module ExploreQueues
  class CreateCommand < BaseCommand
    attr_reader :user_game, :params, :game_data, :buildings

    def initialize(user_game:, explore_queue_params:)
      @user_game = user_game
      @params = explore_queue_params
      @game_data = PrepareGameDataCommand.new(
        game: user_game.game, civilization: user_game.civilization
      ).call.with_indifferent_access
      @buildings = PrepareBuildingsDataCommand.new(civilization: user_game.civilization).call.with_indifferent_access

      super()
    end

    def call
      validate_explorers
      return if failed?

      create_explore_queue
      update_user_game
    rescue StandardError => e
      @errors << e.message
    end

    private

    def validate_explorers
      quantity = params[:quantity].to_i
      horse_setting = params[:horse_setting]

      # Basic validations
      if user_game.people <= quantity
        @errors << "You don't have that many people."
      end

      # Horse validations
      required_horses = calculate_horses(quantity, horse_setting)
      if required_horses > 0 && user_game.horses < required_horses
        @errors << "You do not have enough horses to send with your explorers (You need #{required_horses})."
      end

      # Food validation
      food_needed = calculate_food_needed(quantity)
      if user_game.food < food_needed
        @errors << "You don't have that much food."
      end

      # Maximum explorers validation
      total_explorers = user_game.explore_queues.where('turn > 0').sum(:people) + quantity
      max_explorers = user_game.town_center * buildings[:town_center][:settings][:max_explorers]
      if total_explorers > max_explorers
        @errors << "You can only have a total of #{max_explorers} explorers at a time."
      end
    end

    def create_explore_queue
      trip_length = calculate_trip_length(params[:horse_setting])
      horses_used = calculate_horses(params[:quantity].to_i, params[:horse_setting])
      food_needed = calculate_food_needed(params[:quantity].to_i)

      user_game.explore_queues.create!(
        people: params[:quantity],
        horse_setting: params[:horse_setting],
        seek_land: params[:seek_land],
        food: food_needed,
        horses: horses_used,
        turn: trip_length,
        turns_used: 0
      )
    end

    def update_user_game
      quantity = params[:quantity].to_i
      horses_used = calculate_horses(quantity, params[:horse_setting])
      food_needed = calculate_food_needed(quantity)

      user_game.update!(
        people: user_game.people - quantity,
        food: user_game.food - food_needed,
        horses: user_game.horses - horses_used
      )
    end

    def calculate_trip_length(horse_setting)
      base_length = 6
      case horse_setting
      when 'one_horse'
        base_length + 2
      when 'two_horses'
        base_length + 4
      when 'three_horses'
        base_length + 6
      else
        base_length
      end
    end

    def calculate_horses(quantity, horse_setting)
      case horse_setting
      when 'one_horse'
        quantity
      when 'two_horses'
        quantity * 2
      when 'three_horses'
        quantity * 3
      else
        0
      end
    end

    def calculate_food_needed(quantity)
      food_per_explorer = UserGames::FoodPerExplorerCommand.new(
        user_game: user_game,
        buildings: buildings,
        game_data: game_data
      ).call
      food_per_explorer * quantity
    end
  end
end
