module Games
  class CreateBuildingsCommand < BaseCommand
    attr_reader :game

    def initialize(game:)
      @game = game
    end

    def call
      buildings_data = [
        {
          name: 'Hunter',
          key: 'hunter',
          position: 0,
          settings: {
            land: :forest,
            workers: 6,
            squares: 2,
            food_eaten: 0,
            cost_wood: 4,
            cost_iron: 0,
            cost_gold: 25,
            allow_off: true,
            production: 3,
            production_name: 'food'
          }
        },
        {
          name: 'Farm',
          key: 'farm',
          position: 1,
          settings: {
            land: :plain,
            workers: 12,
            squares: 4,
            food_eaten: 0,
            cost_wood: 8,
            cost_iron: 1,
            cost_gold: 25,
            allow_off: true,
            production: 8,
            production_name: 'food'
          }
        },
        {
          name: 'Wood Cutter',
          key: 'wood_cutter',
          position: 2,
          settings: {
            land: :forest,
            workers: 6,
            squares: 4,
            food_eaten: 0,
            cost_wood: 2,
            cost_iron: 0,
            cost_gold: 25,
            allow_off: true,
            production: 4,
            production_name: 'wood'
          }
        },
        {
          name: 'Iron Mine',
          key: 'iron_mine',
          position: 3,
          settings: {
            land: :mountain,
            workers: 8,
            squares: 2,
            cost_wood: 6,
            cost_iron: 0,
            cost_gold: 100,
            allow_off: true,
            production: 1,
            production_name: 'iron'
          }
        },
        {
          name: 'Gold Mine',
          key: 'gold_mine',
          position: 4,
          settings: {
            land: :mountain,
            workers: 12,
            squares: 6,
            cost_wood: 10,
            cost_iron: 10,
            cost_gold: 1000,
            allow_off: true,
            production: 100,
            production_name: 'gold'
          }
        },
        {
          name: 'Winery',
          key: 'winery',
          position: 5,
          settings: {
            land: :plain,
            workers: 12,
            squares: 6,
            food_eaten: 0,
            cost_wood: 12,
            cost_iron: 4,
            cost_gold: 1000,
            allow_off: true,
            production: 1,
            wine_gold_need: 10,
            production_name: 'wine'
          }
        },
        {
          name: 'Tool Maker',
          key: 'tool_maker',
          position: 6,
          settings: {
            land: :plain,
            workers: 10,
            squares: 2,
            food_eaten: 0,
            cost_wood: 6,
            cost_iron: 2,
            cost_gold: 200,
            allow_off: true,
            production: 1,
            tool_wood_need: 2,
            tool_iron_need: 2,
            production_name: 'tools',
            num_builders: 6
          }
        },
        {
          name: 'Weaponsmith',
          key: 'weaponsmith',
          position: 7,
          settings: {
            land: :plain,
            workers: 10,
            squares: 4,
            food_eaten: 0,
            cost_wood: 10,
            cost_iron: 4,
            cost_gold: 600,
            allow_off: true,
            production: 1,
            bow_wood_need: 25,
            sword_iron_need: 25,
            mace_wood_need: 6,
            mace_iron_need: 6,
            production_name: 'weapons'
          }
        },
        {
          name: 'Fort',
          key: 'fort',
          position: 10,
          settings: {
            land: :plain,
            workers: 0,
            squares: 12,
            food_eaten: 2,
            cost_wood: 20,
            cost_iron: 8,
            cost_gold: 1000,
            allow_off: false,
            max_train: 2,
            max_units: 15,
            need_gold: 25
          }
        },
        {
          name: 'Tower',
          key: 'tower',
          position: 11,
          settings: {
            land: :plain,
            workers: 0,
            squares: 4,
            food_eaten: 0,
            cost_wood: 20,
            cost_iron: 20,
            cost_gold: 400,
            allow_off: false,
            defense_points: 50
          }
        },
        {
          name: 'Town Center',
          key: 'town_center',
          position: 12,
          settings: {
            land: :plain,
            workers: 0,
            squares: 25,
            food_eaten: 0,
            cost_wood: 100,
            cost_iron: 40,
            cost_gold: 2500,
            allow_off: false,
            max_train: 2,
            max_units: 10,
            people: 100,
            resources_limit_increase: 1000,
            max_explorers: 6,
            food_per_explorer: 5,
            max_local_trades: 100
          }
        },
        {
          name: 'Market',
          key: 'market',
          position: 13,
          settings: {
            land: :plain,
            workers: 6,
            squares: 4,
            food_eaten: 0,
            cost_wood: 20,
            cost_iron: 2,
            cost_gold: 250,
            allow_off: false,
            max_trades: 50
          }
        },
        {
          name: 'Warehouse',
          key: 'warehouse',
          position: 14,
          settings: {
            land: :plain,
            workers: 4,
            squares: 2,
            food_eaten: 0,
            cost_wood: 15,
            cost_iron: 0,
            cost_gold: 100,
            allow_off: false,
            resources_limit_increase: 2500
          }
        },
        {
          name: 'Stable',
          key: 'stable',
          position: 8,
          settings: {
            land: :plain,
            workers: 12,
            squares: 4,
            food_eaten: 0,
            cost_wood: 10,
            cost_iron: 2,
            cost_gold: 200,
            allow_off: true,
            production: 1,
            food_need: 100,
            production_name: 'horses'
          }
        },
        {
          name: 'Mage Tower',
          key: 'mage_tower',
          position: 9,
          settings: {
            land: :plain,
            workers: 20,
            squares: 10,
            food_eaten: 0,
            cost_wood: 50,
            cost_iron: 50,
            cost_gold: 2000,
            allow_off: true,
            production: 1,
            research_gold_need: 100,
            production_name: 'research_points'
          }
        },
        {
          name: 'House',
          key: 'house',
          position: 10,
          settings: {
            land: :plain,
            workers: 0,
            squares: 2,
            food_eaten: 1,
            cost_wood: 4,
            cost_iron: 0,
            cost_gold: 100,
            allow_off: false,
            people: 100
          }
        }
      ]

      buildings_data.each do |building_data|
        Building.find_or_create_by!(game_id: game.id, key: building_data[:key]) do |building|
          building.name = building_data[:name]
          building.settings = building_data[:settings]
          building.position = building_data[:position]
        end
      end
    end
  end
end
