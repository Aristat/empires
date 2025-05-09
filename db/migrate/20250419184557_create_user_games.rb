class CreateUserGames < ActiveRecord::Migration[8.0]
  def change
    create_table :user_games do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.references :civilization, null: false, foreign_key: true

      t.bigint :score, null: false, default: 0
      t.integer :turn, null: false, default: 0
      t.datetime :last_turn_at
      t.integer :current_turns, null: false, default: 0
      t.integer :food_ratio, null: false, default: 0

      # builders
      t.integer :tool_maker, null: false, default: 0
      t.integer :wood_cutter, null: false, default: 0
      t.integer :gold_mine, null: false, default: 0
      t.integer :hunter, null: false, default: 0
      t.integer :tower, null: false, default: 0
      t.integer :town_center, null: false, default: 0
      t.integer :market, null: false, default: 0
      t.integer :iron_mine, null: false, default: 0
      t.integer :house, null: false, default: 0
      t.integer :farm, null: false, default: 0
      t.integer :weaponsmith, null: false, default: 0
      t.integer :fort, null: false, default: 0
      t.integer :warehouse, null: false, default: 0
      t.integer :stable, null: false, default: 0
      t.integer :mage_tower, null: false, default: 0
      t.integer :winery, null: false, default: 0

      # buildings statuses
      t.integer :hunter_status, null: false, default: 100
      t.integer :farm_status, null: false, default: 100
      t.integer :wood_cutter_status, null: false, default: 100
      t.integer :gold_mine_status, null: false, default: 100
      t.integer :iron_mine_status, null: false, default: 100
      t.integer :tool_maker_status, null: false, default: 100
      t.integer :winery_status, null: false, default: 100
      t.integer :weaponsmith_status, null: false, default: 100
      t.integer :stable_status, null: false, default: 100
      t.integer :mage_tower_status, null: false, default: 100

      # land
      t.integer :f_land, null: false, default: 0
      t.integer :m_land, null: false, default: 0
      t.integer :p_land, null: false, default: 0

      # resources
      t.integer :wood, null: false, default: 0
      t.integer :food, null: false, default: 0
      t.integer :iron, null: false, default: 0
      t.integer :gold, null: false, default: 0
      t.integer :tools, null: false, default: 0
      t.integer :people, null: false, default: 0
      t.integer :wine, null: false, default: 0
      t.integer :horses, null: false, default: 0

      # weapons
      t.integer :bow_weaponsmith, null: false, default: 0
      t.integer :sword_weaponsmith, null: false, default: 0
      t.integer :mace_weaponsmith, null: false, default: 0
      t.integer :bows, null: false, default: 0
      t.integer :swords, null: false, default: 0
      t.integer :maces, null: false, default: 0

      t.integer :wall, null: false, default: 0
      t.integer :wall_build_per_turn, null: false, default: 0

      t.timestamps
    end
  end
end
