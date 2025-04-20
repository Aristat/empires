civilizations_data = [
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

civilizations_data.each do |civilization_data|
  Civilization.find_or_create_by!(name: civilization_data[:name]) do |civilization|
    civilization.description = civilization_data[:description]
    civilization.military = civilization_data[:military]
    civilization.construction = civilization_data[:construction]
    civilization.research = civilization_data[:research]
  end
  puts "Created/Updated civilization: #{civilization_data[:name]}"
end 