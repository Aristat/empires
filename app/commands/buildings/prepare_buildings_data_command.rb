module Buildings
  class PrepareBuildingsDataCommand
    def initialize(user_game:)
      @user_game = user_game
      @civilization = user_game.civilization
    end

    def call
      Building.all.map do |building|
        settings = OverrideBuildingSettingsCommand.new(
          building: building,
          civilization: @civilization
        ).call

        {
          id: building.id,
          name: building.name,
          key: building.key,
          land_type: settings['land'],
          production_name: settings['production_name'],
          allow_off: settings['allow_off'],
          # consumption: calculate_consumption(building.key, building_count, settings)
        }
      end
    end

    private

    # def calculate_consumption(building_key, count, settings)
    #   case building_key
    #   when 'tool_maker'
    #     {
    #       wood: count * settings['wood_need'],
    #       iron: count * settings['iron_need']
    #     }
    #   when 'weaponsmith'
    #     {
    #       wood: count * settings['wood_need'],
    #       iron: count * settings['iron_need']
    #     }
    #   when 'stable'
    #     {
    #       food: count * settings['food_need']
    #     }
    #   when 'mage_tower'
    #     {
    #       gold: count * settings['gold_need']
    #     }
    #   when 'winery'
    #     {
    #       gold: count * settings['gold_need']
    #     }
    #   else
    #     {}
    #   end
    # end
  end
end 