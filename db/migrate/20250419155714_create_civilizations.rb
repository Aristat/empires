class CreateCivilizations < ActiveRecord::Migration[8.0]
  def change
    create_table :civilizations do |t|
      t.references :game, null: false, foreign_key: true
      t.string :name
      t.string :key, null: false
      t.text :description
      t.jsonb :settings, null: false, default: {}

      t.timestamps
    end

    add_index :civilizations, %i[game_id key], unique: true
  end
end
