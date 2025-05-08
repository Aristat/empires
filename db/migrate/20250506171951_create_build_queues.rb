class CreateBuildQueues < ActiveRecord::Migration[7.1]
  def change
    create_table :build_queues do |t|
      t.references :user_game, null: false, foreign_key: true
      t.integer :turn_added, null: false, default: 0
      t.integer :iron, null: false, default: 0
      t.integer :wood, null: false, default: 0
      t.integer :gold, null: false, default: 0
      t.integer :building_type, null: false
      t.integer :queue_type, null: false
      t.integer :position, null: false
      t.integer :quantity, null: false, default: 0
      t.integer :time_needed, null: false, default: 0
      t.boolean :on_hold, null: false, default: false

      t.timestamps
    end

    add_index :build_queues, [:user_game_id, :position]
  end
end
