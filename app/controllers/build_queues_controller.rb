class BuildQueuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game

  def create
    command = BuildQueues::CreateCommand.new(user_game: @user_game, build_queue_params: build_queue_params)
    command.call

    if command.failed?
      flash[:alert] = "#{command.errors.join("\n")}"
    end

    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end

  def build_queue_params
    params.permit(:building_queue_type, :building_quantity, :building_type)
  end
end
