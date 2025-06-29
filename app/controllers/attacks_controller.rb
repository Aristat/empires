class AttacksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game

  def army_attack
    command = AttackQueues::CreateArmyAttackCommand.new(user_game: @user_game, army_attack_params: army_attack_params)
    command.call

    if command.success?
      flash[:notice] = command.messages.join("\n")
    else
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def catapult_attack
    redirect_to game_path(@user_game.game)
  end

  def thief_attack
    redirect_to game_path(@user_game.game)
  end

  def cancel_attack
    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end

  def army_attack_params
    params.permit(
      :attack_type, :to_user_game_id, :send_all, :cost_wine, :maximum_wine, :unique_unit, :archer, :swordsman,
      :horseman, :catapult, :maceman, :trained_peasant
    )
  end
end
