class PrepareDataCommand < BaseCommand
  attr_reader :user_game

  def initialize(user_game:)
    @user_game = user_game
  end

  def call
    game_data = PrepareGameDataCommand.new(game: user_game.game, civilization: user_game.civilization).call
    buildings = PrepareBuildingsDataCommand.new(civilization: user_game.civilization).call

    {
      game_data: game_data,
      buildings: buildings,
    }
  end
end
