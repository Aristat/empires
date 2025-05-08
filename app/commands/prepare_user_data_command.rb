class PrepareUserDataCommand < BaseCommand
  attr_reader :user_game, :buildings, :game_data

  def initialize(user_game:, buildings:, game_data:)
    @user_game = user_game
    @buildings = buildings
    @game_data = game_data
  end

  def call
    user_data = {}.with_indifferent_access

    used_mountains = user_game.iron_mine * buildings[:iron_mine][:settings][:squares] +
      user_game.gold_mine * buildings[:gold_mine][:settings][:squares]
    used_forest = user_game.wood_cutter * buildings[:wood_cutter][:settings][:squares] +
      user_game.hunter * buildings[:hunter][:settings][:squares]
    used_plains = user_game.farm * buildings[:farm][:settings][:squares] +
      user_game.house * buildings[:house][:settings][:squares] +
      user_game.market * buildings[:market][:settings][:squares] +
      user_game.warehouse * buildings[:warehouse][:settings][:squares] +
      user_game.town_center * buildings[:town_center][:settings][:squares] +
      user_game.stable * buildings[:stable][:settings][:squares] +
      user_game.tool_maker * buildings[:tool_maker][:settings][:squares] +
      user_game.weaponsmith * buildings[:weaponsmith][:settings][:squares] +
      user_game.fort * buildings[:fort][:settings][:squares] +
      user_game.tower * buildings[:tower][:settings][:squares] +
      user_game.winery * buildings[:winery][:settings][:squares] +
      user_game.mage_tower * buildings[:mage_tower][:settings][:squares]

    total_workers = 0
    total_land = 0

    [
      :wood_cutter, :hunter, :farm, :gold_mine, :iron_mine, :tool_maker, :winery, :mage_tower, :weaponsmith, :fort,
      :tower, :town_center, :market, :warehouse, :stable, :house
    ].each do |key|
      count = user_game.send(key)

      if user_game.has_attribute?("#{key}_status")
        status = user_game.send("#{key}_status")
        working = (count * (status / 100.0)).round
        workers = working * buildings[key][:settings][:workers].to_i
      else
        working = 0
        workers = 0
      end
      total_workers += workers

      land = count * buildings[key][:settings][:squares]
      total_land += land

      production =
        if buildings[key][:settings][:production_name]
          "#{working * buildings[key][:settings][:production]} #{buildings[key][:settings][:production_name]}"
        else
          nil
        end

      consumption =
        if key == :tool_maker
          "#{working * buildings[key][:settings][:wood_need]} wood\n" \
            "#{working * buildings[key][:settings][:iron_need]} iron"
        elsif key == :winery
          "#{working * buildings[key][:settings][:gold_need]} gold"
        else
          nil
        end

      user_data[key] = {
        count: count,
        status: status,
        working: working,
        workers: workers,
        production: production,
        consumption: consumption,
        land: land
      }.compact
    end

    num_builders = buildings[:tool_maker][:settings][:num_builders] * user_game.tool_maker + Building::DEFAULT_NUM_BUILDERS

    total_wall = (total_land * 0.05).round
    wall_protection = total_wall > 0 && total_land > 0 ? ((user_game.wall.to_f / total_wall) * 100).round : 0
    wall_build_per_turn = user_game.wall_build_per_turn / 100.0
    wall_builders = (num_builders * wall_build_per_turn).round
    wall_build = (wall_builders / 25.0).to_i

    free_people = user_game.people - total_workers - num_builders
    total_workers += free_people if free_people < 0

    house_space = user_game.house * buildings[:house][:settings][:people] +
      user_game.town_center * buildings[:town_center][:settings][:people]
    free_house_space = house_space - user_game.people

    extra_food_per_land = (total_land.to_f / game_data[:extra_food_per_land]).ceil
    food_per_explorer = buildings[:town_center][:settings][:food_per_explorer] + extra_food_per_land
    max_explorers = user_game.town_center * buildings[:town_center][:settings][:max_explorers]
    send_explorers = (user_game.food / food_per_explorer).floor
    total_explorers = user_game.explore_queues.sum { _1.people }
    can_send_explorers = [ max_explorers - total_explorers, send_explorers ].min

    user_data[:used_mountains] = used_mountains
    user_data[:free_mountains] = user_game.m_land - used_mountains
    user_data[:used_forest] = used_forest
    user_data[:free_forest] = user_game.f_land - used_forest
    user_data[:used_plains] = used_plains
    user_data[:free_plains] = user_game.p_land - used_plains
    user_data[:num_builders] = num_builders
    user_data[:total_wall] = total_wall
    user_data[:wall_protection] = wall_protection
    user_data[:wall_builders] = wall_builders
    user_data[:wall_build] = wall_build
    user_data[:total_workers] = total_workers
    user_data[:total_land] = total_land
    user_data[:free_people] = free_people
    user_data[:free_house_space] = free_house_space

    user_data[:food_per_explorer] = food_per_explorer
    user_data[:max_explorers] = max_explorers
    user_data[:send_explorers] = send_explorers
    user_data[:total_explorers] = total_explorers
    user_data[:can_send_explorers] = can_send_explorers
    user_data[:efficiency_of_explore] = UserGames::CalculateEfficiencyOfExploreCommand.new(
      total_land: total_land
    ).call

    user_data
  end
end
