class TradesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_game

  def local_buy
    command = Trades::LocalBuyCommand.new(user_game: @user_game, local_buy_params: local_buy_params)
    command.call

    if command.success?
      flash[:notice] = command.messages.join("\n")
    else
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def local_sell
    command = Trades::LocalSellCommand.new(user_game: @user_game, local_sell_params: local_sell_params)
    command.call

    if command.success?
      flash[:notice] = command.messages.join("\n")
    else
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def global_sell
    command = Trades::GlobalSellCommand.new(user_game: @user_game, global_sell_params: global_sell_params)
    command.call

    if command.success?
      flash[:notice] = command.messages.join("\n")
    else
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def update_auto_trade
    command = Trades::UpdateAutoTradeCommand.new(
      user_game: @user_game, update_auto_trade_params: update_auto_trade_params
    )
    command.call

    if command.success?
      flash[:notice] = command.messages.join("\n")
    else
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def global_change_prices
    transfer_queue = @user_game.transfer_queues.find(params[:transfer_queue_id])

    command = Trades::GlobalChangePricesCommand.new(
      user_game: @user_game, transfer_queue: transfer_queue, global_change_prices_params: global_change_prices_params
    )
    command.call

    if command.success?
      flash[:notice] = command.messages.join("\n") if command.messages.present?
    else
      flash[:alert] = command.errors.join("\n")
    end

    redirect_to game_path(@user_game.game)
  end

  def global_withdraw
    render json: { success: true }
  end

  private

  def set_user_game
    @user_game = current_user.user_games.find(params[:user_game_id])
  end

  def local_buy_params
    params.permit(:buy_wood, :buy_food, :buy_iron, :buy_tools)
  end

  def local_sell_params
    params.permit(:sell_wood, :sell_food, :sell_iron, :sell_tools)
  end

  def global_sell_params
    params.permit(
      :sell_wood, :price_wood, :sell_food, :price_food, :sell_iron, :price_iron, :sell_tools, :price_tools,
      :sell_swords, :price_swords, :sell_bows, :price_bows, :sell_maces, :price_maces, :sell_horses, :price_horses
    )
  end

  def global_change_prices_params
    params.permit(
      :transfer_queue_id, :price_wood, :price_food, :price_iron, :price_tools, :price_swords, :price_bows, :price_maces,
      :price_horses
    )
  end

  def update_auto_trade_params
    params.permit(
      :auto_buy_wood, :auto_buy_food, :auto_buy_iron, :auto_buy_tools, :auto_sell_wood, :auto_sell_food,
      :auto_sell_iron, :auto_sell_tools
    )
  end
end
