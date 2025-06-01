class CreateBuildings < ActiveRecord::Migration[7.1]
  def change
    create_table :buildings do |t|
      t.references :game, null: false, foreign_key: true
      t.string :name, null: false
      t.string :key, null: false
      t.jsonb :settings, null: false, default: {}
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :buildings, %i[game_id key], unique: true
  end
end