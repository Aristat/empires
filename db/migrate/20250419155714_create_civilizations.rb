class CreateCivilizations < ActiveRecord::Migration[8.0]
  def change
    create_table :civilizations do |t|
      t.string :name
      t.text :description
      t.jsonb :bonuses

      t.timestamps
    end
  end
end
