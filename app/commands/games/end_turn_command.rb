module Games
  class EndTurnCommand
    WINTER_MONTHS = [ 11, 12, 1, 2 ].freeze

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

      # produced
      @p_wood = 0
      @p_food = 0
      @p_iron = 0
      @p_gold = 0
      @p_tools = 0
      @p_wine = 0

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
        calculate_builders
        hunters_production
        farms_production

        @r_food += @p_food

        wood_production
        winter_time

        gold_production
        iron_production
        tools_production

        people_eat_food
        update_resources

        if @user_game.people <= 100
          @user_game.people = 100
        end

        @user_game.turn += 1
        @user_game.current_turns -= 1
        @user_game.last_message = @messages
        @user_game.save!
      end

      true
    end

    private

    def add_message(message, color = nil)
      @messages << { text: message, color: color }
    end

    def calculate_builders
      tool_maker_building = @data[:buildings][:tool_maker][:settings]

      num_builders = tool_maker_building[:num_builders] * @user_game.tool_maker

      if num_builders > @user_game.people
        num_builders = (@user_game.people / 2).round
        add_message("Not enough people to work as builders.", "warning")
      end

      # Limit builders to available tools
      if num_builders > @user_game.tools
        add_message("You do not have enough tools for all of your builders", "danger")
        num_builders = @user_game.tools
      end

      @num_builders = num_builders
    end

    def hunters_production
      return if @user_game.hunter <= 0 || @user_game.hunter_status <= 0

      hunter_building = @data[:buildings][:hunter][:settings]

      can_produce = (@user_game.hunter * (@user_game.hunter_status / 100.0)).round
      people_need = can_produce * hunter_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / hunter_building[:workers]).to_i
        add_message("Not enough people to work at hunters.", "warning")
      end

      @r_people -= can_produce * hunter_building[:workers]
      get_food = can_produce * hunter_building[:production]
      @p_food += get_food
      add_message("Hunters produced #{get_food} food", "success")
    end

    def farms_production
      return if @user_game.farmer <= 0 || @user_game.farmer_status <= 0

      farm_building = @data[:buildings][:farmer][:settings]

      if @month >= 4 && @month <= 10
        can_produce = (@user_game.farmer * (@user_game.farmer_status / 100.0)).round
        people_need = can_produce * farm_building[:workers]

        if @r_people < people_need
          can_produce = (@r_people / farm_building[:workers]).to_i
          add_message("Not enough people to work on farms.", "warning")
        end

        @r_people -= can_produce * farm_building[:workers]
        get_food = can_produce * farm_building[:production]
        @p_food += get_food
        add_message("Farms produced #{get_food} food", "success")
      else
        add_message("Farms are not producing during winter months.", "info")
      end
    end

    def wood_production
      return if @user_game.wood_cutter <= 0 || @user_game.wood_cutter_status <= 0

      wood_cutter_building = @data[:buildings][:wood_cutter][:settings]

      can_produce = (@user_game.wood_cutter * (@user_game.wood_cutter_status / 100.0)).round
      people_need = can_produce * wood_cutter_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / wood_cutter_building[:workers]).to_i
        add_message("Not enough people to work at woodcutters.", "warning")
      end

      @r_people -= can_produce * wood_cutter_building[:workers]
      get_wood = can_produce * wood_cutter_building[:production]
      @p_wood = get_wood
      @r_wood += @p_wood
      add_message("Woodcutters produced #{get_wood} wood", "success")
    end

    def winter_time
      burn_wood = (@user_game.people / @data[:game_data][:people_burn_one_wood]).round

      if WINTER_MONTHS.include?(@month)
        @r_wood = @r_wood - burn_wood
        @c_wood = @c_wood + burn_wood
        add_message("#{burn_wood} wood was used for heat", "info")

        if @r_wood < 0
          people_with_no_heat = ((@r_wood.abs * @data[:game_data][:people_burn_one_wood]) / 8.0).ceil
          people_with_no_heat = @user_game.people - 1 if people_with_no_heat > @user_game.people

          people_freeze = rand((people_with_no_heat / 2)..people_with_no_heat)
          @user_game.people -= people_freeze

          add_message("#{people_freeze} people froze to death due to the lack of wood for heat", "danger")
          @r_wood = 0
        end
      end
    end

    def gold_production
      return if @user_game.gold_mine <= 0 || @user_game.gold_mine_status <= 0

      gold_mine_building = @data[:buildings][:gold_mine][:settings]

      can_produce = (@user_game.gold_mine * (@user_game.gold_mine_status / 100.0)).round
      people_need = can_produce * gold_mine_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / gold_mine_building[:workers]).to_i
        add_message("Not enough people to work at gold mines.", "warning")
      end

      @r_people -= can_produce * gold_mine_building[:workers]
      get_gold = can_produce * gold_mine_building[:production]
      @p_gold = get_gold
      @r_gold += @p_gold
      add_message("Gold mines produced #{get_gold} gold", "success")
    end

    def iron_production
      return if @user_game.iron_mine <= 0 || @user_game.iron_mine_status <= 0

      iron_mine_building = @data[:buildings][:iron_mine][:settings]

      can_produce = (@user_game.iron_mine * (@user_game.iron_mine_status / 100.0)).round
      people_need = can_produce * iron_mine_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / iron_mine_building[:workers]).to_i
        add_message("Not enough people to work at iron mines.", "warning")
      end

      @r_people -= can_produce * iron_mine_building[:workers]
      get_iron = can_produce * iron_mine_building[:production]
      @p_iron = get_iron
      @r_iron += @p_iron
      add_message("Iron mines produced #{get_iron} iron", "success")
    end

    def tools_production
      return if @user_game.tool_maker <= 0 || @user_game.tool_maker_status <= 0

      tool_maker_building = @data[:buildings][:tool_maker][:settings]

      can_produce = (@user_game.tool_maker * (@user_game.tool_maker_status / 100.0)).round
      people_need = can_produce * tool_maker_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / tool_maker_building[:workers]).to_i
        add_message("Not enough people to work at tool makers.", "warning")
      end

      wood_need = can_produce * tool_maker_building[:wood_need]
      if @r_wood < wood_need
        can_produce = (@r_wood / tool_maker_building[:wood_need]).to_i
        add_message("Not enough wood to work at tool makers.", "warning")
      end

      iron_need = can_produce * tool_maker_building[:iron_need]
      if @r_iron < iron_need
        can_produce = (@r_iron / tool_maker_building[:iron_need]).to_i
        add_message("Not enough iron to work at tool makers.", "warning")
      end

      if can_produce <= 0
        can_produce = 0
      end

      @r_people -= can_produce * tool_maker_building[:workers]

      @c_wood += can_produce * tool_maker_building[:wood_need]
      @r_wood -= can_produce * tool_maker_building[:wood_need]

      @c_iron += can_produce * tool_maker_building[:iron_need]
      @r_iron -= can_produce * tool_maker_building[:iron_need]

      @p_tools = can_produce * tool_maker_building[:production]
      @r_tools += @p_tools
      add_message("Tool makers produced #{@p_tools} tools", "success")
    end

    def people_eat_food
      food_eaten = (@user_game.people / @data[:game_data][:people_eat_one_food]).round

      house_building = @data[:buildings][:house][:settings]
      town_center_building = @data[:buildings][:town_center][:settings]

      add_message("Your people ate #{food_eaten} food", "info")

      @c_food += food_eaten
      @r_food -= food_eaten

      # TODO: growth logic
      @growth = 0

      if @r_food < 0
        people_die = (@user_game.people * 0.07).round
        add_message("#{people_die} people died due to lack of food", "danger")

        @user_game.people -= people_die

        if @user_game.people < (@user_game.town_center + @user_game.house)
          @user_game.people = @user_game.town_center + @user_game.house
        end

        @r_food = 0
        @growth = 0
      end

      house_space = @user_game.house * house_building[:people] + @user_game.town_center * town_center_building[:people]

      if @growth > 0 && house_space > @user_game.people
        people_come = ((@growth / 10000.0) * @user_game.people * @data[:game_data][:pop_increase_modifier]).round
        add_message("Your population increased by #{people_come}", "success")
        @r_people += people_come
        @user_game.people += people_come

        if @user_game.people > house_space
          @user_game.people = house_space
        end
      elsif @growth < 0
        people_leave = ((@growth.abs / 10000.0) * @user_game.people).round
        add_message("Due to poor food rationing your population decreased by #{people_leave} people", "warning")
        @user_game.people -= people_leave
      elsif @growth > 0 && house_space == @user_game.people
        add_message("Lack of housing prevents further growth of population.", "warning")
      end

      # Check if there's enough housing
      if @user_game.people > house_space
        people_leave = ((@user_game.people - house_space) / 2.0).ceil
        @user_game.people -= people_leave
        add_message("Due to lack of housing #{people_leave} people emigrated from your empire", "danger")
      end
    end

    def update_resources
      warehouse_building = @data[:buildings][:warehouse][:settings]
      town_center_building = @data[:buildings][:town_center][:settings]

      can_hold = @user_game.town_center * town_center_building[:resources_limit_increase] +
        @user_game.warehouse * warehouse_building[:resources_limit_increase]

      @user_game.wood = @r_wood
      @user_game.food = @r_food
      @user_game.iron = @r_iron
      @user_game.gold = @r_gold
      @user_game.tools = @r_tools
      @user_game.wine = @r_wine

      total_resources = (@user_game.wood + @user_game.food + @user_game.iron + @user_game.tools +
        @user_game.wine).to_f

      if can_hold < total_resources
        too_much = total_resources - can_hold
        steal_wood = (@user_game.wood / total_resources * too_much).round
        steal_food = (@user_game.food / total_resources * too_much).round
        steal_iron = (@user_game.iron / total_resources * too_much).round
        steal_tools = (@user_game.tools / total_resources * too_much).round
        steal_wine = (@user_game.wine / total_resources * too_much).round

        @user_game.wood -= steal_wood
        @user_game.food -= steal_food
        @user_game.iron -= steal_iron
        @user_game.tools -= steal_tools
        @user_game.wine -= steal_wine

        add_message("Due to lack of storage space, you lost #{steal_wood} wood, #{steal_food} food, #{steal_iron} iron, #{steal_tools} tools, and #{steal_wine} wine", "danger")
      end
    end
  end
end
