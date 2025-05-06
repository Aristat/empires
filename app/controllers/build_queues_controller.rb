class BuildQueuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game

  def create
    Rails.logger.info([ "params", build_queue_params ])

    begin

    rescue StandardError => e
      flash[:alert] = "Error: #{e.message}"
      Rails.logger.error("Build queue error: #{e.message}")
    end

    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end

  def build_queue_params
    params.expect(build_queue: [ :queue_type, :building_quantity, :building_type ])
  end
end
