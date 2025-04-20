# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require_relative 'seeds/buildings'
require_relative 'seeds/civilizations'

games = [
  {
    name: 'Standard',
    seconds_per_turn: 600,
    start_turns: 100,
    max_turns: 400,
  },
  {
    name: 'Blitz',
    seconds_per_turn: 100,
    start_turns: 100,
    max_turns: 800,
  }
]

games.each do |game|
  Game.create!(game)
  puts "Created game: #{game[:name]}"
end

user = User.find_or_initialize_by(
  email: 'test@gmail.com'
)
user.password = '123456'
user.password_confirmation = '123456'
user.save!
