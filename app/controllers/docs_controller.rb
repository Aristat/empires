class DocsController < ApplicationController
  before_action :set_game
  before_action :set_user_game

  VALID_PAGES = %w[
    home basics resources buildings wall army attack explore people research trade aid civs manage
  ].freeze

  def show
    @page = VALID_PAGES.include?(params[:page]) ? params[:page] : 'home'
    @buildings = @game.buildings.order(:position).index_by(&:key)
    @soldiers = @game.soldiers.order(:position).index_by(&:key)
    @civilizations = @game.civilizations.order(:name)
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_user_game
    @user_game = current_user&.user_games&.find_by(game: @game)
  end
end
