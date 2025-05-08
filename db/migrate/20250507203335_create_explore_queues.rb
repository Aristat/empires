class CreateExploreQueues < ActiveRecord::Migration[7.1]
  def change
    create_table :explore_queues do |t|
      t.references :user_game, null: false, foreign_key: true
      t.integer :turn, null: false
      t.integer :people, null: false
      t.integer :food, null: false, default: 0
      t.integer :m_land, null: false, default: 0
      t.integer :p_land, null: false, default: 0
      t.integer :f_land, null: false, default: 0
      t.integer :seek_land, null: false
      t.integer :horse_setting, null: false
      t.integer :horses, null: false
      t.integer :turns_used, null: false

      t.timestamps
    end
  end
end
