class TradesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game

  def local_buy
    p 'data', params

    redirect_to game_path(@user_game.game)
  end

  def local_sell
    p 'data', params

    redirect_to game_path(@user_game.game)
  end

  def update_auto_trade
    p 'data', params

    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end
end
