class PrepareDataCommand < BaseCommand
  attr_reader :user_game

  def initialize(user_game:)
    @user_game = user_game
  end

  def call
    game_data = PrepareGameDataCommand.new(game: user_game.game, civilization: user_game.civilization).call
    buildings = PrepareBuildingsDataCommand.new(civilization: user_game.civilization).call
    user_data = {
      wood_cutter: {
        count: user_game.wood_cutter,
        status: user_game.wood_cutter_status,
      },
      hunter: {
        count: user_game.hunter,
        status: user_game.hunter_status,
      },
      farmer: {
        count: user_game.farmer,
        status: user_game.farmer_status,
      },
      gold_mine: {
        count: user_game.gold_mine,
        status: user_game.gold_mine_status,
      },
      iron_mine: {
        count: user_game.iron_mine,
        status: user_game.iron_mine_status,
      },
      tool_maker: {
        count: user_game.tool_maker,
        status: user_game.tool_maker_status,
      },
      winery: {
        count: user_game.winery,
        status: 100,
      },
      mage_tower: {
        count: user_game.mage_tower,
        status: 100,
      },
      weaponsmith: {
        count: user_game.weaponsmith,
        status: 100,
      },
      fort: {
        count: user_game.fort,
      },
      tower: {
        count: user_game.tower,
      },
      town_center: {
        count: user_game.town_center,
      },
      market: {
        count: user_game.market,
      },
      warehouse: {
        count: user_game.warehouse,
      },
      stable: {
        count: user_game.stable,
        status: 100,
      },
      house: {
        count: user_game.house,
      },
    }
    {
      game_data: game_data,
      buildings: buildings,
      user_data: user_data
    }.with_indifferent_access
  end
end
