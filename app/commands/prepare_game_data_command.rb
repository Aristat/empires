# Game configuration based on civilization
class PrepareGameDataCommand < BaseCommand
  attr_reader :game, :civilization

  def initialize(game:, civilization:)
    @game = game
    @civilization = civilization
  end

  def call
    game_settings = {
      local_wood_sell_price: game.local_wood_sell_price,
      local_wood_buy_price: game.local_wood_buy_price,
      local_food_sell_price: game.local_food_sell_price,
      local_food_buy_price: game.local_food_buy_price,
      local_iron_sell_price: game.local_iron_sell_price,
      local_iron_buy_price: game.local_iron_buy_price,
      local_tools_sell_price: game.local_tools_sell_price,
      local_tools_buy_price: game.local_tools_buy_price,
      people_eat_one_food: game.people_eat_one_food,
      extra_food_per_land: game.extra_food_per_land,
      people_burn_one_wood: game.people_burn_one_wood,
      pop_increase_modifier: game.pop_increase_modifier,
      wall_use_gold: game.wall_use_gold,
      wall_use_iron: game.wall_use_iron,
      wall_use_wood: game.wall_use_wood,
      wall_use_wine: game.wall_use_wine
    }

    civ_overrides = @civilization.settings.dig('game') || {}
    game_settings.merge(civ_overrides)
  end
end
