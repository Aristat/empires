class ExploreQueuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game

  def create
    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end

  def explore_queue_params
    params.permit(:quantity, :horse_setting, :seek_land)
  end
end
