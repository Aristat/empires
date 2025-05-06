class CreateBuildQueues < ActiveRecord::Migration[7.1]
  def change
    create_table :build_queues do |t|
      t.references :user_game, null: false, foreign_key: true
      t.integer :turn_added
      t.integer :iron
      t.integer :wood
      t.integer :gold
      t.integer :building_type
      t.integer :queue_type
      t.integer :position
      t.integer :quantity
      t.integer :time_needed
      t.boolean :on_hold, default: false

      t.timestamps
    end

    add_index :build_queues, [:user_game_id, :position]
  end
end
