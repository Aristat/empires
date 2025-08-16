class AidsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game
  before_action :set_transfer_queue, only: [ :destroy ]

  def create
    command = Aids::CreateCommand.new(user_game: @user_game, aid_params: aid_params)
    command.call

    if command.failed?
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def destroy
    Aids::DeleteCommand.new(user_game: @user_game, transfer_queues: [@transfer_queue]).call
    flash[:notice] = I18n.t('transfer_queues.messages.destroyed')
    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end

  def set_transfer_queue
    @transfer_queue = @user_game.transfer_queues.transfer_type_aid.find(params[:id])
  end

  def aid_params
    params.permit(:quantity, :horse_setting, :seek_land)
  end
end
