class UserGamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game

  def update
    p 'Update!'

    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:id])
  end
end
