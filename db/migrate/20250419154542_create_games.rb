class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :name
      t.integer :seconds_per_turn
      t.integer :start_turns
      t.integer :max_turns
      t.jsonb :settings, null: false, default: {}

      t.timestamps
    end
  end
end
