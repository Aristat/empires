# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require_relative 'seeds/buildings'
require_relative 'seeds/civilizations'

games = [
  {
    name: 'Standard'
  },
  {
    name: 'Blitz'
  }
]

games.each do |game|
  Game.create!(game)
  puts "Created game: #{game[:name]}"
end

user = User.find_orcreate!(
  email: 'test@gmail.com',
  password: '123456',
  password_confirmation: '123456'
)
