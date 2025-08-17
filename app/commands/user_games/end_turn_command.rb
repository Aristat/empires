# frozen_string_literal: true

module UserGames
  class EndTurnCommand
    include ActionView::Helpers::NumberHelper

    WINTER_MONTHS = [11, 12, 1, 2].freeze

    def initialize(user_game:)
      @user_game = user_game
      @data = PrepareDataCommand.new(user_game: @user_game).call
      @messages = []

      temp_turn = @user_game.turn + 1
      @month = temp_turn % 12 + 1
      @year = (temp_turn / 12).floor + 1000

      # remaining
      @r_people = @user_game.people
      @r_wood = @user_game.wood
      @r_food = @user_game.food
      @r_iron = @user_game.iron
      @r_gold = @user_game.gold
      @r_tools = @user_game.tools
      @r_wine = @user_game.wine
      @r_horses = @user_game.horses
      @r_bows = @user_game.bows
      @r_swords = @user_game.swords
      @r_maces = @user_game.maces

      # produced
      @p_wood = 0
      @p_food = 0
      @p_iron = 0
      @p_gold = 0
      @p_tools = 0
      @p_wine = 0
      @p_horses = 0

      # consumed
      @c_wood = 0
      @c_food = 0
      @c_iron = 0
      @c_gold = 0
      @c_tools = 0
      @c_wine = 0
    end

    def call
      return false if @user_game.current_turns <= 0

      @user_game.with_lock do
        process_public_trade
        calculate_builders
        hunters_production
        farms_production

        @r_food += @p_food

        wood_production
        winter_time

        gold_production
        iron_production
        tools_production
        weapons_production
        horses_production
        wine_production
        mage_tower_production
        update_researches
        update_wall

        people_eat_food
        soldiers_eat_food
        process_building_queue
        process_train_queue
        update_tools_for_builders
        process_explorers
        process_auto_trade
        process_attack_queues
        update_maintenance_of_soldiers
        update_resources
        process_aids

        if @user_game.people <= 100
          @user_game.people = 100
        end

        @user_game.turn += 1
        @user_game.current_turns -= 1
        @user_game.last_message = @messages
        @user_game.trades_this_turn = 0
        @user_game.save!
        UserGames::UpdateScoreCommand.new(user_game: @user_game).call
      end

      true
    end

    private

    def add_message(message, color = nil)
      @messages << { text: message, color: color }
    end

    def process_public_trade
      TransferQueue.where(
        '(user_game_id = ? AND turns_remaining > 0 AND transfer_type = ?) OR ' \
        '(to_user_game_id = ? AND turns_remaining > 0 AND transfer_type = ?)',
        @user_game.id, TransferQueue.transfer_types['sell'], @user_game.id, TransferQueue.transfer_types['buy']
      ).update_all('turns_remaining = turns_remaining - 1')

      transfer_entries = TransferQueue.where(to_user_game_id: @user_game.id, turns_remaining: 0, transfer_type: :buy)
      transfer_entries.each do |entry|
        # Generating message for each transport
        resources = []
        TransferQueue::RESOURCES.each do |resource_column|
          next if entry.send(resource_column).blank?

          resources << "#{entry.send(resource_column)} #{resource_column.to_s.humanize}"
        end

        if resources.blank?
          entry.destroy!
          next
        end

        message = +'A transport with '
        message += resources.join(', ')
        message += ' arrived from public market.'
        add_message(message, 'warning')

        @r_wood += entry.wood.to_i
        @r_food += entry.food.to_i
        @r_iron += entry.iron.to_i
        @r_tools += entry.tools.to_i
        @r_maces += entry.maces.to_i
        @r_swords += entry.swords.to_i
        @r_bows += entry.bows.to_i
        @r_horses += entry.horses.to_i

        # Delete the processed entry from the queue
        entry.destroy!
      end
    end

    def calculate_builders
      tool_maker_building = @data[:buildings][:tool_maker][:settings]

      num_builders = tool_maker_building[:num_builders] * @user_game.tool_maker + Building::DEFAULT_NUM_BUILDERS

      if num_builders > @user_game.people
        num_builders = (@user_game.people / 2).round
        add_message('Not enough people to work as builders.', 'warning')
      end

      # Limit builders to available tools
      if num_builders > @user_game.tools
        add_message('You do not have enough tools for all of your builders', 'danger')
        num_builders = @user_game.tools
      end

      @num_builders = num_builders
    end

    def hunters_production
      return if @user_game.hunter <= 0 || @user_game.hunter_status_buildings_statuses <= 0

      hunter_building = @data[:buildings][:hunter][:settings]

      can_produce = (@user_game.hunter * (@user_game.hunter_status_buildings_statuses / 100.0)).round
      people_need = can_produce * hunter_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / hunter_building[:workers]).to_i
        add_message('Not enough people to work at hunters.', 'warning')
      end

      @r_people -= can_produce * hunter_building[:workers]
      get_food = can_produce * hunter_building[:production]
      get_food = get_food + (get_food * (@user_game.food_production_researches / 100.0)).round
      @p_food += get_food
      add_message("Hunters produced #{get_food} food", 'success')
    end

    def farms_production
      return if @user_game.farm <= 0 || @user_game.farm_status_buildings_statuses <= 0

      farm_building = @data[:buildings][:farm][:settings]

      if @month >= 4 && @month <= 10
        can_produce = (@user_game.farm * (@user_game.farm_status_buildings_statuses / 100.0)).round
        people_need = can_produce * farm_building[:workers]

        if @r_people < people_need
          can_produce = (@r_people / farm_building[:workers]).to_i
          add_message('Not enough people to work on farms.', 'warning')
        end

        @r_people -= can_produce * farm_building[:workers]
        get_food = can_produce * farm_building[:production]
        get_food = get_food + (get_food * (@user_game.food_production_researches / 100.0)).round
        @p_food += get_food
        add_message("Farms produced #{get_food} food", 'success')
      else
        add_message('Farms are not producing during winter months.', 'info')
      end
    end

    def wood_production
      return if @user_game.wood_cutter <= 0 || @user_game.wood_cutter_status_buildings_statuses <= 0

      wood_cutter_building = @data[:buildings][:wood_cutter][:settings]

      can_produce = (@user_game.wood_cutter * (@user_game.wood_cutter_status_buildings_statuses / 100.0)).round
      people_need = can_produce * wood_cutter_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / wood_cutter_building[:workers]).to_i
        add_message('Not enough people to work at woodcutters.', 'warning')
      end

      @r_people -= can_produce * wood_cutter_building[:workers]
      get_wood = can_produce * wood_cutter_building[:production]
      get_wood = get_wood + (get_wood * (@user_game.wood_production_researches / 100.0)).round
      @p_wood = get_wood
      @r_wood += @p_wood
      add_message("Woodcutters produced #{get_wood} wood", 'success')
    end

    def winter_time
      burn_wood = (@user_game.people / @data[:game_data][:people_burn_one_wood]).round

      if WINTER_MONTHS.include?(@month)
        @r_wood = @r_wood - burn_wood
        @c_wood = @c_wood + burn_wood
        add_message("#{burn_wood} wood was used for heat", 'info')

        if @r_wood < 0
          people_with_no_heat = ((@r_wood.abs * @data[:game_data][:people_burn_one_wood]) / 8.0).ceil
          people_with_no_heat = @user_game.people - 1 if people_with_no_heat > @user_game.people

          people_freeze = rand((people_with_no_heat / 2)..people_with_no_heat)
          @user_game.people -= people_freeze

          add_message("#{people_freeze} people froze to death due to the lack of wood for heat", 'danger')
          @r_wood = 0
        end
      end
    end

    def gold_production
      return if @user_game.gold_mine <= 0 || @user_game.gold_mine_status_buildings_statuses <= 0

      gold_mine_building = @data[:buildings][:gold_mine][:settings]

      can_produce = (@user_game.gold_mine * (@user_game.gold_mine_status_buildings_statuses / 100.0)).round
      people_need = can_produce * gold_mine_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / gold_mine_building[:workers]).to_i
        add_message('Not enough people to work at gold mines.', 'warning')
      end

      @r_people -= can_produce * gold_mine_building[:workers]
      get_gold = can_produce * gold_mine_building[:production]
      get_gold = get_gold + (get_gold * (@user_game.mine_production_researches / 100.0)).round
      @p_gold = get_gold
      @r_gold += @p_gold
      add_message("Gold mines produced #{get_gold} gold", 'success')
    end

    def iron_production
      return if @user_game.iron_mine <= 0 || @user_game.iron_mine_status_buildings_statuses <= 0

      iron_mine_building = @data[:buildings][:iron_mine][:settings]

      can_produce = (@user_game.iron_mine * (@user_game.iron_mine_status_buildings_statuses / 100.0)).round
      people_need = can_produce * iron_mine_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / iron_mine_building[:workers]).to_i
        add_message('Not enough people to work at iron mines.', 'warning')
      end

      @r_people -= can_produce * iron_mine_building[:workers]
      get_iron = can_produce * iron_mine_building[:production]
      get_iron = get_iron + (get_iron * (@user_game.mine_production_researches / 100.0)).round
      @p_iron = get_iron
      @r_iron += @p_iron
      add_message("Iron mines produced #{get_iron} iron", 'success')
    end

    def tools_production
      return if @user_game.tool_maker <= 0 || @user_game.tool_maker_status_buildings_statuses <= 0

      tool_maker_building = @data[:buildings][:tool_maker][:settings]

      can_produce = (@user_game.tool_maker * (@user_game.tool_maker_status_buildings_statuses / 100.0)).round
      people_need = can_produce * tool_maker_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / tool_maker_building[:workers]).to_i
        add_message('Not enough people to work at tool makers.', 'warning')
      end

      wood_need = can_produce * tool_maker_building[:tool_wood_need]
      if @r_wood < wood_need
        can_produce = (@r_wood / tool_maker_building[:tool_wood_need]).to_i
        add_message('Not enough wood to work at tool makers.', 'warning')
      end

      iron_need = can_produce * tool_maker_building[:tool_iron_need]
      if @r_iron < iron_need
        can_produce = (@r_iron / tool_maker_building[:tool_iron_need]).to_i
        add_message('Not enough iron to work at tool makers.', 'warning')
      end

      if can_produce <= 0
        can_produce = 0
      end

      @r_people -= can_produce * tool_maker_building[:workers]

      @c_wood += can_produce * tool_maker_building[:tool_wood_need]
      @r_wood -= can_produce * tool_maker_building[:tool_wood_need]

      @c_iron += can_produce * tool_maker_building[:tool_iron_need]
      @r_iron -= can_produce * tool_maker_building[:tool_iron_need]

      get_tools = can_produce * tool_maker_building[:production]
      get_tools = get_tools + (get_tools * (@user_game.weapons_tools_production_researches / 100.0)).round
      @p_tools = get_tools
      @r_tools += @p_tools
      add_message("Tool makers produced #{@p_tools} tools", 'success')
    end

    def weapons_production
      return if @user_game.weaponsmith <= 0 || @user_game.weaponsmith_status_buildings_statuses <= 0

      # Check if total assigned weaponsmiths exceed total available
      if @user_game.sword_weaponsmith + @user_game.bow_weaponsmith + @user_game.mace_weaponsmith > @user_game.weaponsmith
        bow_ratio = 0
        mace_ratio = 0
        sword_ratio = 0
        had_buildings = @user_game.sword_weaponsmith + @user_game.bow_weaponsmith + @user_game.mace_weaponsmith
        has_buildings = @user_game.weaponsmith

        if had_buildings > 0
          bow_ratio = @user_game.bow_weaponsmith.to_f / had_buildings
          sword_ratio = @user_game.sword_weaponsmith.to_f / had_buildings
          mace_ratio = @user_game.mace_weaponsmith.to_f / had_buildings
        end

        @user_game.bow_weaponsmith = (has_buildings * bow_ratio).to_i
        @user_game.sword_weaponsmith = (has_buildings * sword_ratio).to_i
        @user_game.mace_weaponsmith = (has_buildings * mace_ratio).to_i
      end

      weaponsmith_building = @data[:buildings][:weaponsmith][:settings]

      # Produce swords
      can_produce = (@user_game.sword_weaponsmith * (@user_game.weaponsmith_status_buildings_statuses / 100.0)).round
      people_need = can_produce * weaponsmith_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / weaponsmith_building[:workers]).to_i
        add_message('Not enough people to produce swords.', 'warning')
      end

      iron_need = can_produce * weaponsmith_building[:sword_iron_need]
      if @r_iron < iron_need
        can_produce = (@r_iron / weaponsmith_building[:sword_iron_need]).to_i
        add_message('Not enough iron to produce all swords.', 'warning')
      end

      can_produce = 0 if can_produce < 0

      @r_people -= can_produce * weaponsmith_building[:workers]
      @c_iron += can_produce * weaponsmith_building[:sword_iron_need]
      @r_iron -= can_produce * weaponsmith_building[:sword_iron_need]

      p_swords = can_produce * weaponsmith_building[:production]
      p_swords = p_swords + (p_swords * (@user_game.weapons_tools_production_researches / 100.0)).round
      @r_swords += p_swords

      # Produce bows
      can_produce = (@user_game.bow_weaponsmith * (@user_game.weaponsmith_status_buildings_statuses / 100.0)).round
      people_need = can_produce * weaponsmith_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / weaponsmith_building[:workers]).to_i
        add_message('Not enough people to produce bows.', 'warning')
      end

      wood_need = can_produce * weaponsmith_building[:bow_wood_need]
      if @r_wood < wood_need
        can_produce = (@r_wood / weaponsmith_building[:bow_wood_need]).to_i
        add_message('Not enough wood to produce all bows.', 'warning')
      end

      can_produce = 0 if can_produce < 0

      @r_people -= can_produce * weaponsmith_building[:workers]
      @c_wood += can_produce * weaponsmith_building[:bow_wood_need]
      @r_wood -= can_produce * weaponsmith_building[:bow_wood_need]

      p_bows = can_produce * weaponsmith_building[:production]
      p_bows = p_bows + (p_bows * (@user_game.weapons_tools_production_researches / 100.0)).round
      @r_bows += p_bows

      # Produce maces
      can_produce = (@user_game.mace_weaponsmith * (@user_game.weaponsmith_status_buildings_statuses / 100.0)).round
      people_need = can_produce * weaponsmith_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / weaponsmith_building[:workers]).to_i
        add_message('Not enough people to produce maces.', 'warning')
      end

      wood_need = can_produce * weaponsmith_building[:mace_wood_need]
      if @r_wood < wood_need
        can_produce = (@r_wood / weaponsmith_building[:mace_wood_need]).to_i
        add_message('Not enough wood to produce all maces.', 'warning')
      end

      iron_need = can_produce * weaponsmith_building[:mace_iron_need]
      if @r_iron < iron_need
        can_produce = (@r_iron / weaponsmith_building[:mace_iron_need]).to_i
        add_message('Not enough iron to produce all maces.', 'warning')
      end

      can_produce = 0 if can_produce < 0

      @r_people -= can_produce * weaponsmith_building[:workers]
      @c_wood += can_produce * weaponsmith_building[:mace_wood_need]
      @r_wood -= can_produce * weaponsmith_building[:mace_wood_need]
      @c_iron += can_produce * weaponsmith_building[:mace_iron_need]
      @r_iron -= can_produce * weaponsmith_building[:mace_iron_need]

      p_maces = can_produce * weaponsmith_building[:production]
      p_maces = p_maces + (p_maces * (@user_game.weapons_tools_production_researches / 100.0)).round
      @r_maces += p_maces

      # Add production messages
      add_message("Produced #{p_swords} swords", 'success') if p_swords > 0
      add_message("Produced #{p_bows} bows", 'success') if p_bows > 0
      add_message("Produced #{p_maces} maces", 'success') if p_maces > 0
    end

    def horses_production
      return if @user_game.stable <= 0 || @user_game.stable <= 0

      stable_building = @data[:buildings][:stable][:settings]

      can_produce = (@user_game.stable * (@user_game.stable_status_buildings_statuses / 100.0)).round
      people_need = can_produce * stable_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / stable_building[:workers]).to_i
        add_message('Not enough people to work at stables.', 'warning')
      end

      food_need = can_produce * stable_building[:food_need]
      if @r_food < food_need
        can_produce = (@r_food / stable_building[:food_need]).to_i
      end

      can_produce = 0 if can_produce < 0
      @r_people = @r_people - (can_produce * stable_building[:workers])
      @c_food += can_produce * stable_building[:food_need]
      @r_food -= can_produce * stable_building[:food_need]

      @p_horses = can_produce * stable_building[:production]
      @r_horses += @p_horses
      add_message("Stables produced #{@p_horses} horses", 'success')
    end

    def wine_production
      return if @user_game.winery <= 0 || @user_game.winery_status_buildings_statuses <= 0

      winery_building = @data[:buildings][:winery][:settings]

      can_produce = (@user_game.winery * (@user_game.winery_status_buildings_statuses / 100.0)).round
      people_need = can_produce * winery_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / winery_building[:workers]).to_i
        add_message('Not enough people to work at wineries.', 'warning')
      end

      gold_need = can_produce * winery_building[:wine_gold_need]
      if @r_gold < gold_need
        can_produce = (@r_gold / winery_building[:wine_gold_need]).to_i
        add_message('Not enough gold to work at wineries.', 'warning')
      end

      can_produce = 0 if can_produce < 0

      @r_people = @r_people - (can_produce * winery_building[:workers])

      @c_gold += can_produce * winery_building[:wine_gold_need]
      @r_gold -= can_produce * winery_building[:wine_gold_need]

      @p_wine = can_produce * winery_building[:production]
      @r_wine += @p_wine
      add_message("Wineries produced #{@p_wine} wine", 'success')
    end

    def mage_tower_production
      return if @user_game.mage_tower <= 0 || @user_game.mage_tower_status_buildings_statuses <= 0 || @user_game.current_research.blank?

      mage_tower_building = @data[:buildings][:mage_tower][:settings]
      can_produce = (@user_game.mage_tower * (@user_game.mage_tower_status_buildings_statuses / 100.0)).round

      people_need = can_produce * mage_tower_building[:workers]
      if @r_people < people_need
        can_produce = (@r_people / mage_tower_building[:workers]).to_i
        add_message('Not enough people to work at mage towers.', 'red')
      end

      gold_need = can_produce * mage_tower_building[:research_gold_need]
      if @r_gold < gold_need
        can_produce = (@r_gold / mage_tower_building[:research_gold_need]).to_i
        add_message('Not enough gold to do all research.', 'red')
      end

      can_produce = 0 if can_produce < 0

      @r_people -= can_produce * mage_tower_building[:workers]
      @c_gold += can_produce * mage_tower_building[:research_gold_need]
      @r_gold -= can_produce * mage_tower_building[:research_gold_need]

      @user_game.research_points += (can_produce * mage_tower_building[:production]).round
    end

    def update_researches
      return if @user_game.current_research.blank? || @user_game.research_points <= 0

      total_research_levels = Researches::TotalResearchLevelsCommand.new(user_game: @user_game).call
      need_research_points = Researches::NextResearchLevelPointsCommand.new(
        total_research_levels: total_research_levels
      ).call

      while @user_game.research_points >= need_research_points
        if @user_game.current_research == 'military_losses' && @user_game.military_losses_researches >= 50
          add_message('You can only have up to 50 research levels for military loss', 'red')
          break
        end

        @user_game.research_points -= need_research_points
        total_research_levels += 1

        case @user_game.current_research
        when 'attack_points'
          @user_game.attack_points_researches += 1
        when 'defense_points'
          @user_game.defense_points_researches += 1
        when 'thieves_strength'
          @user_game.thieves_strength_researches += 1
        when 'military_losses'
          @user_game.military_losses_researches += 1
        when 'food_production'
          @user_game.food_production_researches += 1
        when 'mine_production'
          @user_game.mine_production_researches += 1
        when 'weapons_tools_production'
          @user_game.weapons_tools_production_researches += 1
        when 'space_effectiveness'
          @user_game.space_effectiveness_researches += 1
        when 'markets_output'
          @user_game.markets_output_researches += 1
        when 'explorers'
          @user_game.explorers_researches += 1
        when 'catapults_strength'
          @user_game.catapults_strength_researches += 1
        when 'wood_production'
          @user_game.wood_production_researches += 1
        end

        research_name = @user_game.current_research.titleize.gsub('_', ' ')
        add_message("Finished research of #{research_name}", 'warning')
        need_research_points = Researches::NextResearchLevelPointsCommand.new(
          total_research_levels: total_research_levels
        ).call
      end
    end

    def update_wall
      total_land = @user_game.m_land + @user_game.f_land + @user_game.p_land
      total_wall = (total_land * 0.05).round

      # Handle wall decay (25% chance)
      if rand(1..100) <= 25 && @user_game.wall > 10
        decay = (@user_game.wall * (rand(1..100) / 750.0)).round
        if decay > 0
          @user_game.wall -= decay
          add_message("#{decay} units of wall deteriorated", 'danger')
        end
      end

      # Handle wall construction
      if @user_game.wall_build_per_turn > 0 && @user_game.wall < total_wall
        wall_builders = (@num_builders * (@user_game.wall_build_per_turn / 100.0)).round
        can_produce = (wall_builders / 25).to_i

        # Adjust if we would exceed total wall
        if can_produce + @user_game.wall > total_wall
          can_produce = total_wall - @user_game.wall
        end

        # Check resource requirements
        gold_need = can_produce * @data[:game_data][:wall_use_gold]
        if @r_gold < gold_need
          can_produce = (@r_gold / @data[:game_data][:wall_use_gold]).to_i
          add_message('Not enough gold for construction of the great wall.', 'danger')
        end

        wood_need = can_produce * @data[:game_data][:wall_use_wood]
        if @r_wood < wood_need
          can_produce = (@r_wood / @data[:game_data][:wall_use_wood]).to_i
          add_message('Not enough wood for construction of the great wall.', 'danger')
        end

        iron_need = can_produce * @data[:game_data][:wall_use_iron]
        if @r_iron < iron_need
          can_produce = (@r_iron / @data[:game_data][:wall_use_iron]).to_i
          add_message('Not enough iron for construction of the great wall.', 'danger')
        end

        wine_need = can_produce * @data[:game_data][:wall_use_wine]
        if @r_wine < wine_need
          can_produce = (@r_wine / @data[:game_data][:wall_use_wine]).to_i
          add_message('Not enough wine for construction of the great wall.', 'danger')
        end

        if can_produce > 0
          # Update consumed resources
          @c_gold += can_produce * @data[:game_data][:wall_use_gold]
          @r_gold -= can_produce * @data[:game_data][:wall_use_gold]

          @c_wood += can_produce * @data[:game_data][:wall_use_wood]
          @r_wood -= can_produce * @data[:game_data][:wall_use_wood]

          @c_iron += can_produce * @data[:game_data][:wall_use_iron]
          @r_iron -= can_produce * @data[:game_data][:wall_use_iron]

          @c_wine += can_produce * @data[:game_data][:wall_use_wine]
          @r_wine -= can_produce * @data[:game_data][:wall_use_wine]

          # Update wall and builders
          @user_game.wall += can_produce
          @num_builders -= (can_produce * 10)
          add_message("Constructed #{can_produce} units of wall.", 'success')
        end
      end
    end

    def people_eat_food
      food_eaten = (@user_game.people / @data[:game_data][:people_eat_one_food]).round

      house_building = @data[:buildings][:house][:settings]
      town_center_building = @data[:buildings][:town_center][:settings]

      @growth = 0
      case @user_game.food_ratio
      when -2
        @growth = rand(-200..-100)
        food_eaten = (food_eaten * 0.45).round
      when -1
        @growth = rand(-100..-50)
        food_eaten = (food_eaten * 0.75).round
      when 0
        @growth = rand(-30..50)
      when 1
        @growth = rand(50..100)
        food_eaten = (food_eaten * 1.5).round
      when 2
        @growth = rand(100..200)
        food_eaten = (food_eaten * 2.5).round
      when 3
        @growth = rand(200..400)
        food_eaten = (food_eaten * 4).round
      when 4
        @growth = rand(400..800)
        food_eaten = (food_eaten * 8).round
      end

      add_message("Your people ate #{food_eaten} food", 'info')

      @c_food += food_eaten
      @r_food -= food_eaten

      if @r_food < 0
        people_die = (@user_game.people * 0.07).round
        add_message("#{people_die} people died due to lack of food", 'danger')

        @user_game.people -= people_die

        if @user_game.people < (@user_game.town_center + @user_game.house)
          @user_game.people = @user_game.town_center + @user_game.house
        end

        @r_food = 0
        @growth = 0
      end

      house_space = UserGames::HouseSpaceCommand.new(
        user_game: @user_game, buildings: @data[:buildings]
      ).call

      if @growth > 0 && house_space > @user_game.people
        people_come = ((@growth / 10000.0) * @user_game.people * @data[:game_data][:pop_increase_modifier]).round
        add_message("Your population increased by #{people_come}", 'success')
        @r_people += people_come
        @user_game.people += people_come

        if @user_game.people > house_space
          @user_game.people = house_space
        end
      elsif @growth < 0
        people_leave = ((@growth.abs / 10000.0) * @user_game.people).round
        add_message("Due to poor food rationing your population decreased by #{people_leave} people", 'warning')
        @user_game.people -= people_leave
      elsif @growth > 0 && house_space == @user_game.people
        add_message('Lack of housing prevents further growth of population.', 'warning')
      end

      # Check if there's enough housing
      if @user_game.people > house_space
        people_leave = ((@user_game.people - house_space) / 2.0).ceil
        @user_game.people -= people_leave
        add_message("Due to lack of housing #{people_leave} people emigrated from your empire", 'danger')
      end
    end

    def soldiers_eat_food
      food_eaten = (
        @user_game.unique_unit_soldiers * @data[:soldiers][:unique_unit][:settings][:food_eaten] +
        @user_game.swordsman_soldiers * @data[:soldiers][:swordsman][:settings][:food_eaten] +
        @user_game.archer_soldiers * @data[:soldiers][:archer][:settings][:food_eaten] +
        @user_game.horseman_soldiers * @data[:soldiers][:horseman][:settings][:food_eaten] +
        @user_game.macemen_soldiers * @data[:soldiers][:macemen][:settings][:food_eaten] +
        @user_game.trained_peasant_soldiers * @data[:soldiers][:trained_peasant][:settings][:food_eaten] +
        @user_game.thieve_soldiers * @data[:soldiers][:thieve][:settings][:food_eaten]
      ).round

      return if food_eaten <= 0

      @c_food += food_eaten
      @r_food -= food_eaten
      add_message("Your soldiers ate #{number_with_delimiter(food_eaten)} food")

      if @r_food < 0
        # 5% of army dies when there isn't enough food
        survival_rate = 0.95
        add_message('Some soldiers died due to the lack of food', 'danger')

        @user_game.unique_unit_soldiers = (@user_game.unique_unit_soldiers * survival_rate).round
        @user_game.swordsman_soldiers = (@user_game.swordsman_soldiers * survival_rate).round
        @user_game.archer_soldiers = (@user_game.archer_soldiers * survival_rate).round
        @user_game.horseman_soldiers = (@user_game.horseman_soldiers * survival_rate).round
        @user_game.macemen_soldiers = (@user_game.macemen_soldiers * survival_rate).round
        @user_game.trained_peasant_soldiers = (@user_game.trained_peasant_soldiers * survival_rate).round
        @user_game.thieve_soldiers = (@user_game.thieve_soldiers * survival_rate).round

        @r_food = 0
      end
    end

    def process_building_queue
      m_used = @data[:user_data][:used_mountains]
      f_used = @data[:user_data][:used_forest]
      p_used = @data[:user_data][:used_plains]

      build_moves = @num_builders

      @user_game.build_queues.active.ordered.each do |queue|
        building = @data[:buildings][queue.building_type.to_sym]

        # Check available land
        has_land = case building[:settings][:land]
        when 'mountain'
                    @user_game.m_land - m_used
        when 'forest'
                    @user_game.f_land - f_used
        when 'plain'
                    @user_game.p_land - p_used
        end

        if has_land <= 0 && queue.queue_type == 'build'
          add_message("You do not have any free #{building[:settings][:land]} land to build #{building[:name]}", 'danger')
          next
        end

        b_need_time = building[:settings][:cost_wood] + building[:settings][:cost_iron] # time needed for one building

        time_remaining = queue.time_needed
        if build_moves > time_remaining # we can finish all buildings
          build_moves -= time_remaining
          time_remaining = 0
        else
          time_remaining -= build_moves
          build_moves = 0
        end

        # Calculate how many buildings were built or demolished
        qty_remaining = (time_remaining.to_f / b_need_time).ceil
        qty_build = queue.quantity - qty_remaining

        land_taken = qty_build * building[:settings][:squares]
        if land_taken > has_land && queue.queue_type == 'build' # cannot build, not enough land
          # Calculate how many can be built
          qty_build = (has_land / building[:settings][:squares]).floor
          qty_remaining = queue.quantity - qty_build
          build_moves += qty_remaining * b_need_time
          time_remaining = qty_remaining * b_need_time
          land_taken = qty_build * building[:settings][:squares]

          add_message("Not enough land (#{qty_remaining * building[:settings][:squares]} #{building[:settings][:land]}) to process construction of #{building[:name]}", 'danger')
        end

        constructed = false
        if qty_build > 0 && queue.queue_type == 'build' # built some buildings
          add_message("Finished construction of #{qty_build} #{building[:name]}s", 'success')
          case building[:settings][:land]
          when 'mountain'
            m_used += land_taken
          when 'forest'
            f_used += land_taken
          when 'plain'
            p_used += land_taken
          end

          had_buildings = @user_game.send(queue.building_type)
          has_buildings = had_buildings + qty_build
          constructed = true
        elsif qty_build > 0 && queue.queue_type == 'demolish' # demolished some buildings
          add_message("Demolished #{qty_build} #{building[:name]}s", 'success')
          case building[:settings][:land]
          when 'mountain'
            m_used -= land_taken
          when 'forest'
            f_used -= land_taken
          when 'plain'
            p_used -= land_taken
          end

          had_buildings = @user_game.send(queue.building_type)
          has_buildings = had_buildings - qty_build
          constructed = true
        end

        if constructed
          # recalculate weapons production
          if queue.building_type == 'weaponsmith'
            bow_ratio = 0
            mace_ratio = 0
            sword_ratio = 0

            if had_buildings > 0
              bow_ratio = @user_game.bow_weaponsmith.to_f / had_buildings
              sword_ratio = @user_game.sword_weaponsmith.to_f / had_buildings
              mace_ratio = @user_game.mace_weaponsmith.to_f / had_buildings
            end

            @user_game.bow_weaponsmith = (has_buildings * bow_ratio).to_i
            @user_game.sword_weaponsmith = (has_buildings * sword_ratio).to_i
            @user_game.mace_weaponsmith = (has_buildings * mace_ratio).to_i
          end

          @user_game.send("#{queue.building_type}=", has_buildings)
        end

        if time_remaining == 0
          queue.destroy
        else
          queue.update(
            time_needed: time_remaining,
            quantity: qty_remaining
          )
        end
      end
    end

    def process_train_queue
      @trained_unique_unit = 0
      @trained_swordsman = 0
      @trained_archers = 0
      @trained_horseman = 0
      @trained_macemen = 0
      @trained_catapults = 0
      @trained_trained_peasants = 0
      @trained_thieves = 0

      total_soldiers_limit = TrainQueues::SoldiersLimitCommand.new(
        user_game: @user_game,
        buildings: @data[:buildings]
      ).call
      total_army = UserGames::TotalArmyCommand.new(user_game: @user_game).call

      @user_game.train_queues.update_all('turns_remaining = turns_remaining - 1') # rubocop:disable Rails/SkipsModelValidations
      @user_game.train_queues.where('turns_remaining <= 0').find_each do |queue|
        done = true
        train_qty = queue.quantity

        if queue.turns_remaining < 0
          add_message("#{number_with_delimiter(train_qty)} training army units were disbanded because of lack of forts", 'danger')
          @user_game.people += train_qty
        else
          if total_army + train_qty > total_soldiers_limit
            done = false
            train_qty = total_soldiers_limit - total_army
            train_qty = 0 if train_qty < 0
            add_message('Not enough forts to finish training army', 'danger')
          end

          case queue.soldier_key
          when 'unique_unit'
            @trained_unique_unit += train_qty
            @user_game.unique_unit_soldiers += train_qty
          when 'archer'
            @trained_archers += train_qty
            @user_game.archer_soldiers += train_qty
          when 'swordsman'
            @trained_swordsman += train_qty
            @user_game.swordsman_soldiers += train_qty
          when 'horseman'
            @trained_horseman += train_qty
            @user_game.horseman_soldiers += train_qty
          when 'catapult'
            @trained_catapults += train_qty
            @user_game.catapult_soldiers += train_qty
          when 'macemen'
            @trained_macemen += train_qty
            @user_game.macemen_soldiers += train_qty
          when 'trained_peasant'
            @trained_trained_peasants += train_qty
            @user_game.trained_peasant_soldiers += train_qty
          when 'thieve'
            @trained_thieves += train_qty
            @user_game.thieve_soldiers += train_qty
          end
        end

        if done
          queue.destroy
        else
          queue.update(quantity: queue.quantity - train_qty)
        end
      end

      add_message("#{number_with_delimiter(@trained_unique_unit)} #{@data[:soldiers][:unique_unit][:name]} have finished their training and are ready to serve you", 'success') if @trained_unique_unit > 0
      add_message("#{number_with_delimiter(@trained_swordsman)} swordsmen have finished their training and are ready to serve you", 'success') if @trained_swordsman > 0
      add_message("#{number_with_delimiter(@trained_archers)} archers have finished their training and are ready to serve you", 'success') if @trained_archers > 0
      add_message("#{number_with_delimiter(@trained_horseman)} horsemen have finished their training and are ready to serve you", 'success') if @trained_horseman > 0
      add_message("#{number_with_delimiter(@trained_macemen)} macemen have finished their training and are ready to serve you", 'success') if @trained_macemen > 0
      add_message("#{number_with_delimiter(@trained_catapults)} catapults have finished their training and are ready to serve you", 'success') if @trained_catapults > 0
      add_message("#{number_with_delimiter(@trained_trained_peasants)} trained peasants have finished their training and are ready to serve you", 'success') if @trained_trained_peasants > 0
      add_message("#{number_with_delimiter(@trained_thieves)} thieves have finished their training and are ready to serve you", 'success') if @trained_thieves > 0
    end

    def update_tools_for_builders
      # Only process in months 5 and 10
      return unless [5, 10].include?(@month)

      # Calculate tools used (10-20% of builders)
      tools_used = rand(10..20)
      tools_used = (@num_builders * tools_used / 100.0).round

      return if tools_used <= 0

      add_message("#{number_with_delimiter(tools_used)} tools wore out")

      if @r_tools >= tools_used
        # If has enough tools, supply builders with them
        @r_tools -= tools_used
      else
        @r_tools = 0
      end
    end

    def process_explorers
      @user_game.explore_queues.order(:id).each do |queue|
        if queue.turn.zero?
          queue.destroy
          next
        end

        # Calculate base land discovery
        mountain_land = (queue.people * 0.13).ceil
        forest_land = (queue.people * 0.26).ceil
        plain_land = (queue.people * 0.58).ceil

        # Calculate minimum land discovery
        mountain_min = (mountain_land / 3.0).round
        forest_min = (forest_land / 3.0).round
        plains_min = (plain_land / 3.0).round

        # Adjust based on land type preference
        case queue.seek_land
        when 'mountain_land'
          mountain_land *= 3
          mountain_min *= 3
          forest_land = 0
          forest_min = 0
          plain_land = 0
          plains_min = 0
        when 'forest_land'
          mountain_land = 0
          mountain_min = 0
          forest_land = (forest_land * 2.5).round
          forest_min = (forest_min * 2.5).round
          plain_land = 0
          plains_min = 0
        when 'plain_land'
          mountain_land = 0
          mountain_min = 0
          forest_land = 0
          forest_min = 0
          plain_land *= 2
          plains_min *= 2
        end

        # Randomize land discovery within range
        mountain_land = rand(mountain_min..mountain_land)
        forest_land = rand(forest_min..forest_land)
        plain_land = rand(plains_min..plain_land)

        if @user_game.explorers_researches > 0
          mountain_land = mountain_land + (mountain_land * (@user_game.explorers_researches / 100.0)).round
          forest_land = forest_land + (forest_land * (@user_game.explorers_researches / 100.0)).round
          plain_land = plain_land + (plain_land * (@user_game.explorers_researches / 100.0)).round
        end

        # Calculate efficiency based on total land
        total_land = @user_game.m_land + @user_game.f_land + @user_game.p_land
        efficiency = if total_land > 500_000
          mult = total_land / 500_000.0
          mult = 99 if mult >= 100
          (100 - mult) / 100.0
        else
          1.0
        end

        # Apply efficiency
        mountain_land = (mountain_land * efficiency).round
        forest_land = (forest_land * efficiency).round
        plain_land = (plain_land * efficiency).round

        # Update user game land
        @user_game.m_land += mountain_land
        @user_game.f_land += forest_land
        @user_game.p_land += plain_land

        # Add discovery message
        if mountain_land.positive? || forest_land.positive? || plain_land.positive?
          add_message(
            "Your explorers have discovered #{mountain_land} mountain land, " \
            "#{forest_land} forest land and #{plain_land} plain land",
            'success'
          )
        else
          add_message('Your explorers did not discover any land this turn', 'info')
        end

        # Update queue
        new_turn = queue.turn - 1
        if new_turn.zero?
          add_message(
            'Your explorers ended their mission discovering total ' \
            "#{queue.m_land + mountain_land} mountain land, " \
            "#{queue.f_land + forest_land} forest land and " \
            "#{queue.p_land + plain_land} plain land",
            'success'
          )
          queue.destroy
          next
        end

        queue.update(
          turn: new_turn,
          turns_used: queue.turns_used + 1,
          m_land: queue.m_land + mountain_land,
          f_land: queue.f_land + forest_land,
          p_land: queue.p_land + plain_land
        )
      end
    end

    def process_auto_trade
      calculate_local_trade_multiplier = Trades::LocalTradeMultiplierCommand.new(user_game: @user_game).call

      if @user_game.auto_sell_wood_trades > 0 && @r_wood >= @user_game.auto_sell_wood_trades
        wood_price = (@data[:game_data][:local_wood_sell_price] * (1.0 / calculate_local_trade_multiplier)).round
        get_gold = wood_price * @user_game.auto_sell_wood_trades
        @r_wood -= @user_game.auto_sell_wood_trades
        @r_gold += get_gold
        add_message(
          "Sold #{number_with_delimiter(@user_game.auto_sell_wood_trades)} wood for #{number_with_delimiter(get_gold)}",
          'success'
        )
      end

      if @user_game.auto_sell_food_trades > 0 && @r_food >= @user_game.auto_sell_food_trades
        food_price = (@data[:game_data][:local_food_sell_price] * (1.0 / calculate_local_trade_multiplier)).round
        get_gold = food_price * @user_game.auto_sell_food_trades
        @r_food -= @user_game.auto_sell_food_trades
        @r_gold += get_gold
        add_message(
          "Sold #{number_with_delimiter(@user_game.auto_sell_food)} food for #{number_with_delimiter(get_gold)}",
          'success'
        )
      end

      if @user_game.auto_sell_iron_trades > 0 && @r_iron >= @user_game.auto_sell_iron_trades
        iron_price = (@data[:game_data][:local_iron_sell_price] * (1.0 / calculate_local_trade_multiplier)).round
        get_gold = iron_price * @user_game.auto_sell_iron_trades
        @r_iron -= @user_game.auto_sell_iron_trades
        @r_gold += get_gold
        add_message(
          "Sold #{number_with_delimiter(@user_game.auto_sell_iron_trades)} iron for #{number_with_delimiter(get_gold)}",
          'success'
        )
      end

      if @user_game.auto_sell_tools_trades > 0 && @r_tools >= @user_game.auto_sell_tools_trades
        tool_price = (@data[:game_data][:local_tools_sell_price] * (1.0 / calculate_local_trade_multiplier)).round
        get_gold = tool_price * @user_game.auto_sell_tools_trades
        @r_tools -= @user_game.auto_sell_tools_trades
        @r_gold += get_gold
        add_message(
          "Sold #{number_with_delimiter(@user_game.auto_sell_tools_trades)} tools for #{number_with_delimiter(get_gold)}",
          'success'
        )
      end

      if @user_game.auto_buy_wood_trades > 0
        wood_price = (@data[:game_data][:local_wood_buy_price] * calculate_local_trade_multiplier).round
        use_gold = wood_price * @user_game.auto_buy_wood_trades
        if @r_gold >= use_gold
          @r_wood += @user_game.auto_buy_wood_trades
          @r_gold -= use_gold
          add_message(
            "Bought #{number_with_delimiter(@user_game.auto_buy_wood_trades)} wood for #{number_with_delimiter(use_gold)}",
            'success'
          )
        end
      end

      if @user_game.auto_buy_food_trades > 0
        food_price = (@data[:game_data][:local_food_buy_price] * calculate_local_trade_multiplier).round
        use_gold = food_price * @user_game.auto_buy_food_trades
        if @r_gold >= use_gold
          @r_food += @user_game.auto_buy_food_trades
          @r_gold -= use_gold
          add_message(
            "Bought #{number_with_delimiter(@user_game.auto_buy_food_trades)} food for #{number_with_delimiter(use_gold)}",
            'success'
          )
        end
      end

      if @user_game.auto_buy_iron_trades > 0
        iron_price = (@data[:game_data][:local_iron_buy_price] * calculate_local_trade_multiplier).round
        use_gold = iron_price * @user_game.auto_buy_iron_trades
        if @r_gold >= use_gold
          @r_iron += @user_game.auto_buy_iron_trades
          @r_gold -= use_gold
          add_message(
            "Bought #{number_with_delimiter(@user_game.auto_buy_iron_trades)} iron for #{number_with_delimiter(use_gold)}",
            'success'
          )
        end
      end

      if @user_game.auto_buy_tools_trades > 0
        tool_price = (@data[:game_data][:local_tools_buy_price] * calculate_local_trade_multiplier).round
        use_gold = tool_price * @user_game.auto_buy_tools_trades
        if @r_gold >= use_gold
          @r_tools += @user_game.auto_buy_tools_trades
          @r_gold -= use_gold
          add_message(
            "Bought #{number_with_delimiter(@user_game.auto_buy_tools_trades)} tools for #{number_with_delimiter(use_gold)}",
            'success'
          )
        end
      end
    end

    def process_attack_queues
      @user_game.attack_queues.where.not(attack_status: :in_home).update_all('attack_status = attack_status + 1')

      in_home_attack_queues = @user_game.attack_queues.where(attack_status: :in_home)
      return if in_home_attack_queues.blank?

      in_home_attack_queues.each do |attack_queue|
        UserGame::SOLDIERS.keys.each do |soldier_key|
          soldiers_count = attack_queue.send("#{soldier_key}_soldiers").to_i
          next if soldiers_count <= 0

          @user_game.send("#{soldier_key}_soldiers=", @user_game.send("#{soldier_key}_soldiers") + soldiers_count)
        end

        attack_queue.destroy!
      end

      add_message('Your army has returned to the empire', 'warning')
    end

    def update_maintenance_of_soldiers
      total_soldiers_limit = TrainQueues::SoldiersLimitCommand.new(
        user_game: @user_game,
        buildings: @data[:buildings]
      ).call
      total_army = UserGames::TotalArmyCommand.new(user_game: @user_game).call

      if total_army > total_soldiers_limit
        too_much = ((total_army - total_soldiers_limit) * 0.25).round
        run_swordsman = ((@user_game.swordsman_soldiers.to_f / total_army) * too_much).round
        run_archers = ((@user_game.archer_soldiers.to_f / total_army) * too_much).round
        run_horseman = ((@user_game.horseman_soldiers.to_f / total_army) * too_much).round
        run_macemen = ((@user_game.macemen_soldiers.to_f / total_army) * too_much).round
        run_trained_peasants = ((@user_game.trained_peasant_soldiers.to_f / total_army) * too_much).round
        run_thieves = ((@user_game.thieve_soldiers.to_f / total_army) * too_much).round
        run_catapults = ((@user_game.catapult_soldiers.to_f / total_army) * too_much).round
        run_unique_unit = ((@user_game.unique_unit_soldiers.to_f / total_army) * too_much).round

        @user_game.unique_unit_soldiers -= run_unique_unit
        @user_game.swordsman_soldiers -= run_swordsman
        @user_game.archer_soldiers -= run_archers
        @user_game.horseman_soldiers -= run_horseman
        @user_game.macemen_soldiers -= run_macemen
        @user_game.trained_peasant_soldiers -= run_trained_peasants
        @user_game.thieve_soldiers -= run_thieves
        @user_game.catapult_soldiers -= run_catapults

        add_message(
          "Due to the lack of place to live some of your soldiers run away (#{run_unique_unit} #{@data[:soldiers][:unique_unit][:name]}, " \
          "#{run_swordsman} #{@data[:soldiers][:swordsman][:name]}, #{run_archers} #{@data[:soldiers][:archer][:name]}, " \
          "#{run_horseman} #{@data[:soldiers][:horseman][:name]}, #{run_macemen} #{@data[:soldiers][:macemen][:name]}, " \
          "#{run_trained_peasants} #{@data[:soldiers][:trained_peasant][:name]}, " \
          "#{run_catapults} #{@data[:soldiers][:catapult][:name]} and #{run_thieves} #{@data[:soldiers][:thieve][:name]})",
          'error'
        )
      end

      pay_gold = (
        @user_game.unique_unit_soldiers * @data[:soldiers][:unique_unit][:settings][:gold_per_turn] +
        @user_game.swordsman_soldiers * @data[:soldiers][:swordsman][:settings][:gold_per_turn] +
        @user_game.archer_soldiers * @data[:soldiers][:archer][:settings][:gold_per_turn] +
        @user_game.horseman_soldiers * @data[:soldiers][:horseman][:settings][:gold_per_turn] +
        @user_game.macemen_soldiers * @data[:soldiers][:macemen][:settings][:gold_per_turn] +
        @user_game.trained_peasant_soldiers * @data[:soldiers][:trained_peasant][:settings][:gold_per_turn] +
        @user_game.thieve_soldiers * @data[:soldiers][:thieve][:settings][:gold_per_turn]
      ).round

      if pay_gold > @r_gold
        temporary_gold_soldiers = @user_game.unique_unit_soldiers + @user_game.swordsman_soldiers +
          @user_game.archer_soldiers + @user_game.horseman_soldiers + @user_game.macemen_soldiers +
          @user_game.trained_peasant_soldiers + @user_game.thieve_soldiers
        not_paid = ((pay_gold - @r_gold) * 0.1).round

        run_unique_unit = ((@user_game.unique_unit_soldiers.to_f / temporary_gold_soldiers) * not_paid).round
        run_swordsman = ((@user_game.swordsman_soldiers.to_f / temporary_gold_soldiers) * not_paid).round
        run_archers = ((@user_game.archer_soldiers.to_f / temporary_gold_soldiers) * not_paid).round
        run_horseman = ((@user_game.horseman_soldiers.to_f / temporary_gold_soldiers) * not_paid).round
        run_macemen = ((@user_game.macemen_soldiers.to_f / temporary_gold_soldiers) * not_paid).round
        run_trained_peasants = ((@user_game.trained_peasant_soldiers.to_f / temporary_gold_soldiers) * not_paid).round
        run_thieves = ((@user_game.thieve_soldiers.to_f / temporary_gold_soldiers) * not_paid).round

        @user_game.unique_unit_soldiers -= run_unique_unit
        @user_game.swordsman_soldiers -= run_swordsman
        @user_game.archer_soldiers -= run_archers
        @user_game.horseman_soldiers -= run_horseman
        @user_game.macemen_soldiers -= run_macemen
        @user_game.trained_peasant_soldiers -= run_trained_peasants
        @user_game.thieve_soldiers -= run_thieves

        add_message(
          "Because you did not have enough gold to pay your soldiers some of them run away (#{run_unique_unit} #{@data[:soldiers][:unique_unit][:name]}, " \
            "#{run_swordsman} #{@data[:soldiers][:swordsman][:name]}, #{run_archers} #{@data[:soldiers][:archer][:name]}, " \
            "#{run_horseman} #{@data[:soldiers][:horseman][:name]}, #{run_macemen} #{@data[:soldiers][:macemen][:name]}, " \
            "#{run_trained_peasants} #{@data[:soldiers][:trained_peasant][:name]} and #{run_thieves} #{@data[:soldiers][:thieve][:name]})",
          'error'
        )

        pay_gold = @r_gold
        @r_gold = 0
        @c_gold += pay_gold
      else
        @r_gold -= pay_gold
        @c_gold += pay_gold
        add_message("Your soldiers have been paid #{number_with_delimiter(pay_gold)} gold", 'success') unless pay_gold.zero?
      end

      if @user_game.unique_unit_soldiers > @user_game.town_center
        too_much = @user_game.unique_unit_soldiers - @user_game.town_center
        @user_game.unique_unit_soldiers -= too_much
        add_message("You do not have enough town centers for your #{@data[:soldiers][:unique_unit][:name]}s. #{too_much} #{@data[:soldiers][:unique_unit][:name]}s run away", 'error')
      end

      # Check special unit requirements
      if @user_game.thieve_soldiers > @user_game.town_center
        too_much = @user_game.thieve_soldiers - @user_game.town_center
        @user_game.thieve_soldiers -= too_much
        add_message("You do not have enough town centers for your thieves. #{too_much} thieves run away", 'error')
      end

      if @user_game.catapult_soldiers > @user_game.town_center
        too_much = @user_game.catapult_soldiers - @user_game.town_center
        @user_game.catapult_soldiers -= too_much
        add_message("You do not have enough town centers for your catapults. #{too_much} catapults run away", 'error')
      end

      need_wood = @user_game.catapult_soldiers * @data[:soldiers][:catapult][:settings][:wood_per_turn]
      if @r_wood < need_wood && @user_game.catapult_soldiers > 0
        run_catapults = ((need_wood - @r_wood) * 0.25).round
        run_catapults = @user_game.catapult_soldiers if run_catapults > @user_game.catapult_soldiers
        add_message("You did not have enough wood to upkeep your catapults. #{run_catapults} of them were destroyed", 'error')
        @user_game.catapult_soldiers -= run_catapults
      else
        @r_wood -= need_wood
      end

      need_iron = (@user_game.catapult_soldiers * @data[:soldiers][:catapult][:settings][:iron_per_turn]).round
      if @r_iron < need_iron && @user_game.catapult_soldiers > 0
        run_catapults = ((need_iron - @r_iron) * 0.25).round
        run_catapults = @user_game.catapult_soldiers if run_catapults > @user_game.catapult_soldiers
        add_message("You did not have enough iron to upkeep your catapults. #{run_catapults} of them were destroyed", 'error')
        @user_game.catapult_soldiers -= run_catapults
      else
        @r_iron -= need_iron
      end

      if need_wood > 0 && need_iron > 0
        add_message("#{need_wood} wood and #{need_iron} iron was used to upkeep catapults", 'success')
      end
    end

    def update_resources
      warehouse_building = @data[:buildings][:warehouse][:settings]
      town_center_building = @data[:buildings][:town_center][:settings]

      can_hold = @user_game.town_center * town_center_building[:resources_limit_increase] +
        @user_game.warehouse * warehouse_building[:resources_limit_increase]
      can_hold = can_hold + (can_hold * (@user_game.space_effectiveness_researches / 100.0)).round

      @user_game.wood = @r_wood
      @user_game.food = @r_food
      @user_game.iron = @r_iron
      @user_game.gold = @r_gold
      @user_game.tools = @r_tools
      @user_game.wine = @r_wine
      @user_game.horses = @r_horses
      @user_game.bows = @r_bows
      @user_game.swords = @r_swords
      @user_game.maces = @r_maces

      total_resources = (@user_game.wood + @user_game.food + @user_game.iron + @user_game.tools +
        @user_game.wine + @user_game.horses).to_f

      if can_hold < total_resources
        too_much = total_resources - can_hold
        steal_wood = (@user_game.wood / total_resources * too_much).round
        steal_food = (@user_game.food / total_resources * too_much).round
        steal_iron = (@user_game.iron / total_resources * too_much).round
        steal_tools = (@user_game.tools / total_resources * too_much).round
        steal_wine = (@user_game.wine / total_resources * too_much).round
        steal_horses = (@user_game.horses / total_resources * too_much).round

        @user_game.wood -= steal_wood
        @user_game.food -= steal_food
        @user_game.iron -= steal_iron
        @user_game.tools -= steal_tools
        @user_game.wine -= steal_wine
        @user_game.horses -= steal_horses

        add_message(
          "Due to lack of storage space, you lost #{steal_wood} wood, #{steal_food} food, #{steal_iron} iron," \
            "#{steal_tools} tools, #{steal_wine} wine and #{steal_horses} horses", 'danger'
        )
      end
    end

    def process_aids
      TransferQueue.where(user_game_id: @user_game.id, transfer_type: :aid)
                   .where('turns_remaining > 0')
                   .update_all('turns_remaining = turns_remaining - 1')

      completed_aids = TransferQueue.where(user_game_id: @user_game.id, transfer_type: :aid, turns_remaining: 0)
                                   .includes(to_user_game: :user)

      completed_aids.each do |aid_transfer|
        recipient = aid_transfer.to_user_game
        next unless recipient

        update_params = {}
        UserGame::AID_RESOURCES.each do |resource|
          amount = aid_transfer.send(resource).to_i
          next if amount <= 0

          current_amount = recipient.send(resource)
          update_params[resource] = current_amount + amount
        end

        recipient.update!(update_params) if update_params.present?

        aid_transfer.destroy!

        add_message("Aid for player #{recipient.user.email} sent", 'warning')
      end
    end
  end
end
