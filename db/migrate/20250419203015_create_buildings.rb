class CreateBuildings < ActiveRecord::Migration[7.1]
  def change
    create_table :buildings do |t|
      t.string :name, null: false
      t.string :key, null: false, index: { unique: true }
      t.jsonb :settings, null: false, default: {}
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end 