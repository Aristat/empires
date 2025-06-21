class AttacksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game

  def army_attack
    redirect_to game_path(@user_game.game)
  end

  def catapult_attack
    redirect_to game_path(@user_game.game)
  end

  def thief_attack
    redirect_to game_path(@user_game.game)
  end

  def cancel_attack
    redirect_to game_path(@user_game.game)
  end
  
  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end
end
