class UserGamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game

  def update
    @user_game.update!(update_params)

    redirect_to game_path(@user_game.game)
  end

  def end_turn
    success = with_user_game_lock do |user_game|
      UserGames::EndTurnCommand.new(user_game: user_game).call
    end

    if success
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  private

  def update_params
    params.permit(
      :food_ratio, :hunter_status_buildings_statuses, :farm_status_buildings_statuses,
      :wood_cutter_status_buildings_statuses, :gold_mine_status_buildings_statuses,
      :iron_mine_status_buildings_statuses,
      :tool_maker_status_buildings_statuses, :winery_status_buildings_statuses,
      :weaponsmith_status_buildings_statuses, :stable_status_buildings_statuses,
      :mage_tower_status_buildings_statuses,
      :wall_build_per_turn, :bow_weaponsmith, :sword_weaponsmith, :mace_weaponsmith, :current_research
    )
  end

  def set_user_game
    @user_game = current_user.user_games.find(params[:id])
  end
end
