# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

games = [
  {
    name: 'Standard',
    seconds_per_turn: 600,
    start_turns: 100,
    max_turns: 400,
    settings: {
      local_wood_sell_price: 30,
      local_wood_buy_price: 32,
      local_food_sell_price: 15,
      local_food_buy_price: 18,
      local_iron_sell_price: 75,
      local_iron_buy_price: 78,
      local_tools_sell_price: 150,
      local_tools_buy_price: 180,
      global_fee_percent: 5,
      global_wood_min_price: 5,
      global_wood_max_price: 80,
      global_food_min_price: 5,
      global_food_max_price: 40,
      global_iron_min_price: 20,
      global_iron_max_price: 250,
      global_tools_min_price: 50,
      global_tools_max_price: 500,
      global_bows_min_price: 100,
      global_bows_max_price: 3000,
      global_swords_min_price: 100,
      global_swords_max_price: 3000,
      global_maces_min_price: 50,
      global_maces_max_price: 1000,
      global_horses_min_price: 100,
      global_horses_max_price: 3000,
      people_eat_one_food: 50,
      extra_food_per_land: 800,
      people_burn_one_wood: 250,
      pop_increase_modifier: 1,
      wall_use_gold: 150,
      wall_use_iron: 2,
      wall_use_wood: 15,
      wall_use_wine: 5
    }
  },
  {
    name: 'Blitz',
    seconds_per_turn: 100,
    start_turns: 100,
    max_turns: 800,
    settings: {
      local_wood_sell_price: 30,
      local_wood_buy_price: 32,
      local_food_sell_price: 15,
      local_food_buy_price: 18,
      local_iron_sell_price: 75,
      local_iron_buy_price: 78,
      local_tools_sell_price: 150,
      local_tools_buy_price: 180,
      global_fee_percent: 5,
      global_wood_min_price: 5,
      global_wood_max_price: 80,
      global_food_min_price: 5,
      global_food_max_price: 40,
      global_iron_min_price: 20,
      global_iron_max_price: 250,
      global_tools_min_price: 50,
      global_tools_max_price: 500,
      global_bows_min_price: 100,
      global_bows_max_price: 3000,
      global_swords_min_price: 100,
      global_swords_max_price: 3000,
      global_maces_min_price: 50,
      global_maces_max_price: 1000,
      global_horses_min_price: 100,
      global_horses_max_price: 3000,
      people_eat_one_food: 50,
      extra_food_per_land: 800,
      people_burn_one_wood: 250,
      pop_increase_modifier: 1,
      wall_use_gold: 150,
      wall_use_iron: 2,
      wall_use_wood: 15,
      wall_use_wine: 5
    }
  }
]

games.each do |game|
  next if Game.exists?(name: game[:name])

  game_entity = Game.create!(game)
  puts "Created game: #{game[:name]}"

  Games::CreateBuildingsCommand.new(game: game_entity).call
  Games::CreateCivilizationsCommand.new(game: game_entity).call
  Games::CreateSoldiersCommand.new(game: game_entity).call
end

user = User.find_or_initialize_by(
  email: 'test@gmail.com'
)
user.password = '123456'
user.password_confirmation = '123456'
user.save!
