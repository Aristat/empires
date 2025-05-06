class BuildQueuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game

  def create
    Rails.logger.info([ "params", params ])

    redirect_to game_path(@user_game.game)
  end

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end
end
