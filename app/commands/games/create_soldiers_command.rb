module Games
  class CreateSoldiersCommand < BaseCommand
    attr_reader :game

    def initialize(game:)
      @game = game
    end

    def call
      soldiers_data = [
        {
          name: 'Unique Unit',
          key: 'unique_unit',
          position: 0,
          soldier_type: :unit,
          settings: {
            turns: 12,
            attack_points: 1,
            defense_points: 1,
            gold_per_turn: 25,
            train_gold: 1000,
            take_land: 0,
            food_eaten: 1
          }
        },
        {
          name: 'Archer',
          key: 'archer',
          position: 1,
          soldier_type: :unit,
          settings: {
            turns: 6,
            attack_points: 4,
            defense_points: 12,
            gold_per_turn: 3,
            train_bows: 1,
            take_land: 0.05,
            food_eaten: 0.5
          }
        },
        {
          name: 'Swordsman',
          key: 'swordsman',
          position: 2,
          soldier_type: :unit,
          settings: {
            turns: 4,
            attack_points: 8,
            defense_points: 6,
            gold_per_turn: 3,
            train_swords: 1,
            take_land: 0.1,
            food_eaten: 0.4
          }
        },
        {
          name: 'Horseman',
          key: 'horseman',
          position: 3,
          soldier_type: :unit,
          settings: {
            turns: 8,
            attack_points: 10,
            defense_points: 10,
            gold_per_turn: 5,
            train_swords: 1,
            train_horses: 1,
            take_land: 0.15,
            food_eaten: 1
          }
        },
        {
          name: 'Tower',
          key: 'tower',
          position: 4,
          soldier_type: :tower,
          settings: {
            turns: -1,
            attack_points: 0,
            defense_points: 50,
            gold_per_turn: 0,
            take_land: 0,
            food_eaten: 0
          }
        },
        {
          name: 'Catapult',
          key: 'catapult',
          position: 5,
          soldier_type: :catapult,
          settings: {
            turns: 8,
            attack_points: 25,
            defense_points: 25,
            gold_per_turn: 0,
            wood_per_turn: 1,
            iron_per_turn: 0.2,
            train_wood: 250,
            train_iron: 250,
            take_land: 0,
            food_eaten: 0,
            wood_eaten: 1,
            iron_eaten: 0.2
          }
        },
        {
          name: 'Macemen',
          key: 'macemen',
          position: 6,
          soldier_type: :unit,
          settings: {
            turns: 3,
            attack_points: 6,
            defense_points: 3,
            gold_per_turn: 2,
            train_maces: 1,
            take_land: 0.06,
            food_eaten: 0.2
          }
        },
        {
          name: 'Trained Peasant',
          key: 'trained_peasant',
          position: 7,
          soldier_type: :unit,
          settings: {
            turns: 1,
            attack_points: 1,
            defense_points: 2,
            gold_per_turn: 0.1,
            take_land: 0.01,
            food_eaten: 0.1
          }
        },
        {
          name: 'Thieves',
          key: 'thieve',
          position: 8,
          soldier_type: :thieve,
          settings: {
            turns: 10,
            attack_points: 50,
            defense_points: 55,
            gold_per_turn: 25,
            take_land: 0,
            food_eaten: 5
          }
        }
      ]

      default_train_settings = {
        food_eaten: 0,
        wood_eaten: 0,
        iron_eaten: 0,
        gold_per_turn: 0,
        wood_per_turn: 0,
        iron_per_turn: 0,
        train_gold: 0,
        train_wood: 0,
        train_iron: 0,
        train_swords: 0,
        train_bows: 0,
        train_maces: 0,
        train_horses: 0
      }

      soldiers_data.each do |soldier_data|
        Soldier.find_or_create_by!(game_id: game.id, key: soldier_data[:key]) do |soldier|
          soldier.name = soldier_data[:name]
          soldier.soldier_type = soldier_data[:soldier_type]
          soldier.settings = default_train_settings.merge(soldier_data[:settings])
          soldier.position = soldier_data[:position]
        end
      end
    end
  end
end
