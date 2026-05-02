class AttacksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game
  before_action :set_attack_queue, only: [:cancel_attack]

  def army_attack
    command = nil
    with_attack_locks(params[:to_user_game_id]) do |user_game|
      command = AttackQueues::CreateArmyAttackCommand.new(user_game: user_game, army_attack_params: army_attack_params)
      command.call
    end
    respond_command(command)
  end

  def catapult_attack
    command = nil
    with_attack_locks(params[:to_user_game_id]) do |user_game|
      command = AttackQueues::CreateCatapultAttackCommand.new(user_game: user_game, catapult_attack_params: catapult_attack_params)
      command.call
    end
    respond_command(command)
  end

  def thief_attack
    command = nil
    with_attack_locks(params[:to_user_game_id]) do |user_game|
      command = AttackQueues::CreateThiefAttackCommand.new(user_game: user_game, thief_attack_params: thief_attack_params)
      command.call
    end
    respond_command(command)
  end

  def cancel_attack
    command = nil
    with_user_game_lock do |user_game|
      command = AttackQueues::CancelAttackCommand.new(user_game: user_game, attack_queue: @attack_queue)
      command.call
    end
    respond_command(command)
  end

  private

  def with_attack_locks(to_user_game_id = nil)
    keys = ["lock:user_game:#{@user_game.id}"]
    keys << "lock:user_game:#{to_user_game_id}" if to_user_game_id.present?
    RedisLockService.with_locks(*keys, timeout: 10) do
      yield UserGame.find(@user_game.id)
    end
  end

  def respond_command(command)
    if command.nil?
      flash[:alert] = I18n.t('errors.server_busy')
    elsif command.success?
      flash[:notice] = command.messages.join("\n")
    else
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

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

  def thief_attack_params
    params.permit(
      :attack_type, :to_user_game_id, :send_all, :thieve
    )
  end
end
