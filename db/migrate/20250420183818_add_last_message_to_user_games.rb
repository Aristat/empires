class AddLastMessageToUserGames < ActiveRecord::Migration[8.0]
  def change
    add_column :user_games, :last_message, :text
  end
end
