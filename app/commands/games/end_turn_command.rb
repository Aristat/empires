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
        people_eat_food

        @user_game.turn += 1
        @user_game.current_turns -= 1
        @user_game.save!
      end

      true
    end

    private

    def calculate_builders
      tool_maker_building = @data[:buildings][:tool_maker][:settings]

      num_builders = tool_maker_building[:num_builders] * @user_game.tool_maker

      if num_builders > @user_game.people
        num_builders = (@user_game.people / 2).round
      end

      # Limit builders to available tools
      if num_builders > @user_game.tools
        @messages << "You do not have enough tools for all of your builders"
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
        @messages << "Not enough people to work at hunters."
      end

      @r_people -= can_produce * hunter_building[:workers]
      get_food = can_produce * hunter_building[:production]
      @p_food += get_food
    end

    def farms_production
      return if @user_game.farmer <= 0 || @user_game.farmer_status <= 0

      farm_building = @data[:buildings][:farmer][:settings]

      if @month >= 4 && @month <= 10
        can_produce = (@user_game.farmer * (@user_game.farmer_status / 100.0)).round
        people_need = can_produce * farm_building[:workers]

        if @r_people < people_need
          can_produce = (@r_people / farm_building[:workers]).to_i
          @messages << "Not enough people to work on farms."
        end

        @r_people -= can_produce * farm_building[:workers]
        get_food = can_produce * farm_building[:production]
        @p_food += get_food
      end
    end

    def wood_production
      return if @user_game.wood_cutter <= 0 || @user_game.wood_cutter_status <= 0

      wood_cutter_building = @data[:buildings][:wood_cutter][:settings]

      can_produce = (@user_game.wood_cutter * (@user_game.wood_cutter_status / 100.0)).round
      people_need = can_produce * wood_cutter_building[:workers]

      if @r_people < people_need
        can_produce = (@r_people / wood_cutter_building[:workers]).to_i
        @messages << "Not enough people to work at woodcutters."
      end

      @r_people -= can_produce * wood_cutter_building[:workers]
      get_wood = can_produce * wood_cutter_building[:production]
      p_wood = get_wood
      @r_wood += p_wood
    end

    def people_eat_food
      burn_wood = (@user_game.people / @data[:game_data][:people_burn_one_wood]).round

      if WINTER_MONTHS.include?(@month)
        @r_wood = @r_wood - burn_wood
        @c_wood = @c_wood + burn_wood
        @messages << "#{burn_wood} wood was used for heat"

        if @r_wood < 0
          people_with_no_heat = ((@r_wood.abs * @data[:game_data][:people_burn_one_wood]) / 8.0).ceil
          people_with_no_heat = @user_game.people - 1 if people_with_no_heat > @user_game.people

          people_freeze = rand((people_with_no_heat / 2)..people_with_no_heat)
          @user_game.people -= people_freeze

          @messages << "#{people_freeze} people froze to death due to the lack of wood for heat"
          @r_wood = 0
        end
      end
    end
  end
end
