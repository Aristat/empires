class GamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game
  before_action :set_user_game, only: [ :show ]
  before_action :update_turns, only: [ :show ]

  def index
    @games = Game.all
  end

  def show
    if @user_game.nil?
      redirect_to select_civilization_game_path(@game) and return
    end

    @data = PrepareDataCommand.new(user_game: @user_game).call
    @month = (@user_game.turn % 12) + 1
    @year = (@user_game.turn / 12).to_i + 1000

    @next_turn_seconds = @game.seconds_per_turn - (Time.current - @user_game.last_turn_at).to_i
  end

  def select_civilization
    @civilizations = Civilization.all
    @user_game = current_user.user_games.find_by(game: @game)

    if @user_game.present?
      redirect_to game_path(@game)
    end
  end

  def join
    @civilization = Civilization.find(params[:civilization_id])

    @user_game = UserGames::CreateCommand.new(
      current_user: current_user,
      game: @game,
      civilization: @civilization
    ).call

    redirect_to game_path(@game)
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def set_user_game
    @user_game = current_user.user_games.find_by(game: @game)
  end

  def update_turns
    return if @user_game.nil?

    current_time = Time.current
    diff_seconds = current_time - @user_game.last_turn_at
    new_turns = (diff_seconds / @game.seconds_per_turn).to_i
    return if new_turns <= 0

    player_turns = @user_game.current_turns + new_turns
    if player_turns > @game.max_turns
        player_turns = @game.max_turns
    end

    @user_game.update(current_turns: player_turns, last_turn_at: current_time)
  end
end
