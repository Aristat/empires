class CreateCivilizations < ActiveRecord::Migration[8.0]
  def change
    create_table :civilizations do |t|
      t.references :game, null: false, foreign_key: true
      t.string :name
      t.string :key, null: false, index: { unique: true }
      t.text :description
      t.jsonb :settings, null: false, default: {}

      t.timestamps
    end
  end
end
