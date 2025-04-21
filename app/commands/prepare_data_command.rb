class PrepareDataCommand < BaseCommand
  attr_reader :user_game

  def initialize(user_game:)
    @user_game = user_game
  end

  def call
    game_data = PrepareGameDataCommand.new(game: user_game.game, civilization: user_game.civilization).call.with_indifferent_access
    buildings = PrepareBuildingsDataCommand.new(civilization: user_game.civilization).call.with_indifferent_access

    used_mountains = user_game.iron_mine * buildings[:iron_mine][:settings][:squares] +
      user_game.gold_mine * buildings[:gold_mine][:settings][:squares]
    used_forest = user_game.wood_cutter * buildings[:wood_cutter][:settings][:squares] +
      user_game.hunter * buildings[:hunter][:settings][:squares]
    used_plains = user_game.farm * buildings[:farm][:settings][:squares] +
      user_game.house * buildings[:house][:settings][:squares] +
      user_game.market * buildings[:market][:settings][:squares] +
      user_game.warehouse * buildings[:warehouse][:settings][:squares] +
      user_game.town_center * buildings[:town_center][:settings][:squares] +
      user_game.stable * buildings[:stable][:settings][:squares] +
      user_game.tool_maker * buildings[:tool_maker][:settings][:squares] +
      user_game.weaponsmith * buildings[:weaponsmith][:settings][:squares] +
      user_game.fort * buildings[:fort][:settings][:squares] +
      user_game.tower * buildings[:tower][:settings][:squares] +
      user_game.winery * buildings[:winery][:settings][:squares] +
      user_game.mage_tower * buildings[:mage_tower][:settings][:squares]

    user_data = {
      used_mountains: used_mountains,
      used_forest: used_forest,
      used_plains: used_plains,

      wood_cutter: {
        count: user_game.wood_cutter,
        status: user_game.wood_cutter_status,
      },
      hunter: {
        count: user_game.hunter,
        status: user_game.hunter_status,
      },
      farm: {
        count: user_game.farm,
        status: user_game.farm_status,
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
    }.with_indifferent_access

    {
      game_data: game_data,
      buildings: buildings,
      user_data: user_data
    }
  end
end
