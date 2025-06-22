class CreateTransferQueues < ActiveRecord::Migration[7.1]
  def change
    create_table :transfer_queues do |t|
      t.references :user_game, null: false, foreign_key: true
      t.references :to_user_game, null: true, foreign_key: { to_table: :user_games }
      t.references :game, null: false, foreign_key: false

      t.integer :transfer_type, null: false
      t.integer :turns_remaining, null: false

      t.integer :gold, null: true
      t.integer :wood, null: true
      t.integer :wood_price, null: true
      t.integer :food, null: true
      t.integer :food_price, null: true
      t.integer :iron, null: true
      t.integer :iron_price, null: true
      t.integer :tools, null: true
      t.integer :tools_price, null: true
      t.integer :swords, null: true
      t.integer :swords_price, null: true
      t.integer :bows, null: true
      t.integer :bows_price, null: true
      t.integer :maces, null: true
      t.integer :maces_price, null: true
      t.integer :horses, null: true
      t.integer :horses_price, null: true
      t.integer :wine, null: true
      t.integer :wine_price, null: true

      t.timestamps
    end
  end
end
