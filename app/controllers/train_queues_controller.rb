class TrainQueuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game
  before_action :set_train_queue, only: [:destroy]

  def create
    command = TrainQueues::CreateCommand.new(user_game: @user_game, train_queue_params: train_queue_params)
    command.call

    if command.failed?
      flash[:alert] = command.errors.join("\n")
    else
      flash[:notice] = t('train_queues.messages.created')
    end

    redirect_to game_path(@user_game.game)
  end

  def destroy
    # if params[:train_queues].present?
    #   # Handle disband action
    #   command = TrainQueues::DisbandCommand.new(user_game: @user_game, train_queue_params: train_queue_params)
    #   command.call
    #
    #   if command.failed?
    #     flash[:alert] = command.errors.join("\n")
    #   else
    #     flash[:notice] = t('train_queues.messages.disbanded')
    #   end
    # else
    #   # Handle single queue deletion
    #   command = TrainQueues::DeleteCommand.new(user_game: @user_game, train_queues: [@train_queue]).call
    #   flash[:notice] = t('train_queues.messages.destroyed')
    # end

    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end

  def set_train_queue
    @train_queue = @user_game.train_queues.find(params[:id])
  end

  def train_queue_params
    params.permit(
      train_queues: [:unique_unit, :archer, :swordsman, :horseman, :catapult, :maceman, :trained_peasant, :thief]
    )[:train_queues]
  end
end
