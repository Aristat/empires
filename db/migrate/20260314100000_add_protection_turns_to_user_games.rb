# frozen_string_literal: true

class AddProtectionTurnsToUserGames < ActiveRecord::Migration[8.0]
  def change
    add_column :user_games, :protection_turns, :integer, default: 0, null: false
  end
end
