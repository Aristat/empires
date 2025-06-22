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
      global_fee_percent: game.global_fee_percent,
      global_withdraw_percent: game.global_withdraw_percent,
      global_wood_min_price: game.global_wood_min_price,
      global_wood_max_price: game.global_wood_max_price,
      global_food_min_price: game.global_food_min_price,
      global_food_max_price: game.global_food_max_price,
      global_iron_min_price: game.global_iron_min_price,
      global_iron_max_price: game.global_iron_max_price,
      global_tools_min_price: game.global_tools_min_price,
      global_tools_max_price: game.global_tools_max_price,
      global_bows_min_price: game.global_bows_min_price,
      global_bows_max_price: game.global_bows_max_price,
      global_swords_min_price: game.global_swords_min_price,
      global_swords_max_price: game.global_swords_max_price,
      global_maces_min_price: game.global_maces_min_price,
      global_maces_max_price: game.global_maces_max_price,
      global_horses_min_price: game.global_horses_min_price,
      global_horses_max_price: game.global_horses_max_price,
      global_wine_min_price: game.global_wine_min_price,
      global_wine_max_price: game.global_wine_max_price,
      people_eat_one_food: game.people_eat_one_food,
      extra_food_per_land: game.extra_food_per_land,
      people_burn_one_wood: game.people_burn_one_wood,
      pop_increase_modifier: game.pop_increase_modifier,
      wall_use_gold: game.wall_use_gold,
      wall_use_iron: game.wall_use_iron,
      wall_use_wood: game.wall_use_wood,
      wall_use_wine: game.wall_use_wine,
      turns_under_protection: game.turns_under_protection
    }

    civ_overrides = @civilization.settings.dig('game') || {}
    game_settings.merge(civ_overrides).with_indifferent_access
  end
end
