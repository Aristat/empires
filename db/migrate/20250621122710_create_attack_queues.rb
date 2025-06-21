class CreateAttackQueues < ActiveRecord::Migration[7.1]
  def change
    create_table :attack_queues do |t|
      t.references :user_game, null: false, foreign_key: true
      t.references :to_user_game, null: true, foreign_key: { to_table: :user_games }
      t.references :game, null: false, foreign_key: false

      # soldiers
      t.jsonb :soldiers, null: false, default: {}

      t.integer :attack_status, null: false
      t.integer :attack_type, null: false

      t.integer :cost_gold, null: true
      t.integer :cost_food, null: true
      t.integer :cost_wood, null: true
      t.integer :cost_iron, null: true
      t.integer :cost_wine, null: true

      t.timestamps
    end
  end
end
