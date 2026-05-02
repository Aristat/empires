class BuildQueuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game
  before_action :set_build_queue, only: [ :update, :destroy ]

  def create
    command = nil
    with_user_game_lock do |user_game|
      command = BuildQueues::CreateCommand.new(user_game: user_game, build_queue_params: build_queue_params)
      command.call
    end

    if command.nil?
      flash[:alert] = I18n.t('errors.server_busy')
    elsif command.failed?
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def update
    acquired = with_user_game_lock do |_user_game|
      if @build_queue.update(build_queue_params.except(:position))
        handle_position_update if build_queue_params[:position].present?
        flash[:notice] = t('build_queues.messages.updated')
      else
        flash[:alert] = t('build_queues.messages.error_updating')
      end
      true
    end

    flash[:alert] = I18n.t('errors.server_busy') unless acquired

    redirect_to game_path(@user_game.game)
  end

  def destroy
    acquired = with_user_game_lock do |user_game|
      BuildQueues::DeleteCommand.new(user_game: user_game, build_queues: [@build_queue]).call
      true
    end

    if acquired
      flash[:notice] = t('build_queues.messages.destroyed')
    else
      flash[:alert] = I18n.t('errors.server_busy')
    end

    redirect_to game_path(@user_game.game)
  end

  def destroy_all
    acquired = with_user_game_lock do |user_game|
      BuildQueues::DeleteCommand.new(user_game: user_game, build_queues: user_game.build_queues).call
      true
    end

    if acquired
      flash[:notice] = t('build_queues.messages.destroyed_all')
    else
      flash[:alert] = I18n.t('errors.server_busy')
    end

    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end

  def set_build_queue
    @build_queue = @user_game.build_queues.find(params[:id])
  end

  def build_queue_params
    params.permit(:building_queue_type, :building_quantity, :building_type, :on_hold, :position)
  end

  def handle_position_update
    position = build_queue_params[:position].to_i
    if position == 0
      @build_queue.move_higher
    elsif position == -1
      @build_queue.move_to_bottom
    end
  end
end
