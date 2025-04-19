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

civilizations.each do |civilization|
  Civilization.create!(civilization)
  puts "Created civilization: #{civilization[:name]}"
end

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

user = User.create!(
  email: 'test@gmail.com',
  password: '123456',
  password_confirmation: '123456'
)
