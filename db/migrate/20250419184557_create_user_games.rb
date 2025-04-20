class CreateUserGames < ActiveRecord::Migration[8.0]
  def change
    create_table :user_games do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.references :civilization, null: false, foreign_key: true

      t.integer :turn
      t.datetime :last_turn_at
      t.integer :current_turns

      # builders
      t.integer :food_ratio
      t.integer :tool_maker
      t.integer :wood_cutter
      t.integer :gold_mine
      t.integer :hunter
      t.integer :tower
      t.integer :town_center
      t.integer :market
      t.integer :iron_mine
      t.integer :house
      t.integer :farmer
      t.integer :weaponsmith
      t.integer :fort
      t.integer :warehouse
      t.integer :stable
      t.integer :mage_tower
      t.integer :winery

      # buildings statuses
      t.integer :hunter_status, default: 100
      t.integer :farmer_status, default: 100
      t.integer :wood_cutter_status, default: 100
      t.integer :gold_mine_status, default: 100
      t.integer :iron_mine_status, default: 100
      t.integer :tool_maker_status, default: 100

      # land
      t.integer :f_land
      t.integer :m_land
      t.integer :p_land
    
      # units
      t.integer :swordsman
      t.integer :archers
      t.integer :horseman
    
      # resources
      t.integer :wood
      t.integer :food
      t.integer :iron
      t.integer :gold
      t.integer :tools
      t.integer :people
      t.integer :wine

      t.timestamps
    end
  end
end
