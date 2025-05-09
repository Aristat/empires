class ExploreQueuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game
  before_action :set_explore_queue, only: [ :destroy ]

  def create
    command = ExploreQueues::CreateCommand.new(user_game: @user_game, explore_queue_params: explore_queue_params)
    command.call

    if command.failed?
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def destroy
    ExploreQueues::DeleteCommand.new(user_game: @user_game, explore_queues: [@explore_queue]).call
    flash[:notice] = t('explore_queues.messages.destroyed')
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
