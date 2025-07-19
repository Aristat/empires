class AttacksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game
  before_action :set_attack_queue, only: [:cancel_attack]

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
    command = AttackQueues::CreateCatapultAttackCommand.new(
      user_game: @user_game, catapult_attack_params: catapult_attack_params
    )
    command.call

    if command.success?
      flash[:notice] = command.messages.join("\n")
    else
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def thief_attack
    redirect_to game_path(@user_game.game)
  end

  def cancel_attack
    command = AttackQueues::CancelAttackCommand.new(
      user_game: @user_game, attack_queue: @attack_queue
    )
    command.call

    if command.success?
      flash[:notice] = command.messages.join("\n")
    else
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end

  def set_attack_queue
    @attack_queue = @user_game.attack_queues.find(params[:id])
  end

  def army_attack_params
    params.permit(
      :attack_type, :to_user_game_id, :send_all, :cost_wine, :maximum_wine, :unique_unit, :archer, :swordsman,
      :horseman, :maceman, :trained_peasant
    )
  end

  def catapult_attack_params
    params.permit(
      :attack_type, :to_user_game_id, :send_all, :catapult
    )
  end
end
