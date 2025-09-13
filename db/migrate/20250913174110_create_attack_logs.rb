class CreateAttackLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :attack_logs do |t|
      t.references :attacker, null: true, foreign_key: { to_table: :user_games }
      t.references :defender, null: true, foreign_key: { to_table: :user_games }

      t.integer :attack_type, null: false
      t.boolean :attacker_wins, null: false

      t.string :attack_message, null: false

      t.jsonb :casualties, null: false, default: {}

      t.timestamps
    end
  end
end
