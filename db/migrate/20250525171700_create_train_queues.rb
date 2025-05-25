class CreateTrainQueues < ActiveRecord::Migration[7.1]
  def change
    create_table :train_queues do |t|
      t.references :user_game, null: false, foreign_key: true
      t.integer :soldier_key, null: false
      t.integer :turns_remaining, null: false
      t.integer :quantity, null: false

      t.timestamps
    end
  end
end
