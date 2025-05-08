class CreateExploreQueues < ActiveRecord::Migration[7.1]
  def change
    create_table :explore_queues do |t|
      t.references :user_game, null: false, foreign_key: true
      t.integer :turn
      t.integer :people
      t.integer :food
      t.integer :m_land
      t.integer :p_land
      t.integer :f_land
      t.integer :seek_land
      t.integer :horses
      t.integer :turns_used

      t.timestamps
    end
  end
end
