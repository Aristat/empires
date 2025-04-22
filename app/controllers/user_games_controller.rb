class UserGamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game

  def update
    @user_game.update!(update_params)

    redirect_to game_path(@user_game.game)
  end

  def end_turn
    render json: { success: false }, status: :unprocessable_entity and return if @user_game.blank?

    command = Games::EndTurnCommand.new(user_game: @user_game)

    if command.call
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  private

  def update_params
    params.permit(:food_ratio)
  end

  def set_user_game
    @user_game = current_user.user_games.find(params[:id])
  end
end
