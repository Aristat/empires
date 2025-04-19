# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing civilizations
Civilization.destroy_all

# Create civilizations
civilizations = [
  {
    name: "Vikings",
    description: "Fierce warriors from the North, masters of naval warfare and raiding",
    military: 1.1,
    construction: 1.0,
    research: 1.0
  },
  {
    name: "Franks",
    description: "Powerful European kingdom known for its strong defensive capabilities",
    military: 1.0,
    construction: 1.1,
    research: 1.0
  },
  {
    name: "Japanese",
    description: "Island nation with highly disciplined warriors and efficient training",
    military: 1.1,
    construction: 1.0,
    research: 1.0
  },
  {
    name: "Byzantines",
    description: "Eastern Roman Empire, center of learning and advanced technology",
    military: 1.0,
    construction: 1.0,
    research: 1.1
  },
  {
    name: "Mongols",
    description: "Nomadic warriors with unmatched cavalry and mobility",
    military: 1.1,
    construction: 1.0,
    research: 1.0
  },
  {
    name: "Incas",
    description: "Advanced civilization with efficient resource management",
    military: 1.0,
    construction: 1.1,
    research: 1.0
  },
  {
    name: "Chinese",
    description: "Ancient civilization with advanced construction techniques",
    military: 1.0,
    construction: 1.1,
    research: 1.0
  },
  {
    name: "Barbarians",
    description: "Fierce tribes known for their raiding and combat prowess",
    military: 1.1,
    construction: 1.0,
    research: 1.0
  }
]

# Create each civilization
civilizations.each do |civilization|
  Civilization.create!(civilization)
  puts "Created civilization: #{civilization[:name]}"
end

puts "Seeded #{Civilization.count} civilizations"
