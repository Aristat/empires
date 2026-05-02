class ExploreQueuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game
  before_action :set_explore_queue, only: [ :destroy ]

  def create
    command = nil
    with_user_game_lock do |user_game|
      command = ExploreQueues::CreateCommand.new(user_game: user_game, explore_queue_params: explore_queue_params)
      command.call
    end

    if command.nil?
      flash[:alert] = I18n.t('errors.server_busy')
    elsif command.failed?
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def destroy
    acquired = with_user_game_lock do |user_game|
      ExploreQueues::DeleteCommand.new(user_game: user_game, explore_queues: [@explore_queue]).call
      true
    end

    if acquired
      flash[:notice] = t('explore_queues.messages.destroyed')
    else
      flash[:alert] = I18n.t('errors.server_busy')
    end

    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end

  def set_explore_queue
    @explore_queue = @user_game.explore_queues.find(params[:id])
  end

  def explore_queue_params
    params.permit(:quantity, :horse_setting, :seek_land)
  end
end
