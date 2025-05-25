class PrepareDataCommand < BaseCommand
  attr_reader :user_game

  def initialize(user_game:)
    @user_game = user_game
  end

  def call
    game_data = PrepareGameDataCommand.new(game: user_game.game, civilization: user_game.civilization).call.with_indifferent_access
    buildings = PrepareBuildingsDataCommand.new(civilization: user_game.civilization).call.with_indifferent_access
    soldiers = PrepareSoldiersDataCommand.new(civilization: user_game.civilization).call.with_indifferent_access
    user_data = PrepareUserDataCommand.new(
      user_game: user_game, buildings: buildings, soldiers: soldiers, game_data: game_data
    ).call.with_indifferent_access

    {
      game_data: game_data,
      buildings: buildings,
      soldiers: soldiers,
      user_data: user_data
    }
  end
end
