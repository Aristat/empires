class BuildQueuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game
  before_action :set_build_queue, only: [ :update, :destroy ]

  def create
    command = BuildQueues::CreateCommand.new(user_game: @user_game, build_queue_params: build_queue_params)
    command.call

    if command.failed?
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def update
    if @build_queue.update(build_queue_params)
      if build_queue_params[:position].present?
        handle_position_update
      end
      flash[:notice] = "Building queue updated successfully"
    else
      flash[:alert] = "Error updating building queue"
    end

    redirect_to game_path(@user_game.game)
  end

  def destroy
    if params[:id].present?
      @build_queue.destroy
      flash[:notice] = "Building queue item removed"
    else
      @user_game.build_queues.destroy_all
      flash[:notice] = "All building queues cleared"
    end

    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end

  def set_build_queue
    @build_queue = @user_game.build_queues.find(params[:id]) if params[:id].present?
  end

  def build_queue_params
    params.permit(:building_queue_type, :building_quantity, :building_type, :on_hold, :position)
  end

  def handle_position_update
    position = build_queue_params[:position].to_i
    if position == 0
      # Move to top
      @build_queue.move_to_top
    elsif position == -1
      # Move to bottom
      @build_queue.move_to_bottom
    end
  end
end
