buildings_data = [
  {
    name: "Wood Cutter",
    key: "wood_cutter",
    attributes: {
      land: "F",
      workers: 6,
      sq: 4,
      food_eaten: 0,
      cost_wood: 2,
      cost_iron: 0,
      cost_gold: 25,
      allow_off: true,
      production: 4,
      production_name: "wood"
    }
  },
  {
    name: "Hunter",
    key: "hunter",
    attributes: {
      land: "F",
      workers: 6,
      sq: 2,
      food_eaten: 0,
      cost_wood: 4,
      cost_iron: 0,
      cost_gold: 25,
      allow_off: true,
      production: 3,
      production_name: "food"
    }
  },
  {
    name: "Farm",
    key: "farmer",
    attributes: {
      land: "P",
      workers: 12,
      sq: 4,
      food_eaten: 0,
      cost_wood: 8,
      cost_iron: 1,
      cost_gold: 25,
      allow_off: true,
      production: 8,
      production_name: "food"
    }
  },
  {
    name: "House",
    key: "house",
    attributes: {
      land: "P",
      workers: 0,
      sq: 2,
      food_eaten: 1,
      cost_wood: 4,
      cost_iron: 0,
      cost_gold: 100,
      allow_off: false,
      people: 100
    }
  },
  {
    name: "Iron Mine",
    key: "iron_mine",
    attributes: {
      land: "M",
      workers: 8,
      sq: 2,
      cost_wood: 6,
      cost_iron: 0,
      cost_gold: 100,
      allow_off: true,
      production: 1,
      production_name: "iron"
    }
  },
  {
    name: "Gold Mine",
    key: "gold_mine",
    attributes: {
      land: "M",
      workers: 12,
      sq: 6,
      cost_wood: 10,
      cost_iron: 10,
      cost_gold: 1000,
      allow_off: true,
      production: 100,
      production_name: "gold"
    }
  },
  {
    name: "Tool Maker",
    key: "tool_maker",
    attributes: {
      land: "P",
      workers: 10,
      sq: 2,
      food_eaten: 0,
      cost_wood: 6,
      cost_iron: 2,
      cost_gold: 200,
      allow_off: true,
      production: 1,
      wood_need: 2,
      iron_need: 2,
      production_name: "tools",
      num_builders: 6
    }
  },
  {
    name: "Weaponsmith",
    key: "weaponsmith",
    attributes: {
      land: "P",
      workers: 10,
      sq: 4,
      food_eaten: 0,
      cost_wood: 10,
      cost_iron: 4,
      cost_gold: 600,
      allow_off: true,
      production: 1,
      wood_need: 25,
      iron_need: 25,
      mace_wood: 6,
      mace_iron: 6,
      production_name: "weapons"
    }
  },
  {
    name: "Fort",
    key: "fort",
    attributes: {
      land: "P",
      workers: 0,
      sq: 12,
      food_eaten: 2,
      cost_wood: 20,
      cost_iron: 8,
      cost_gold: 1000,
      allow_off: false,
      max_train: 2,
      max_units: 15,
      need_gold: 25
    }
  },
  {
    name: "Tower",
    key: "tower",
    attributes: {
      land: "P",
      workers: 0,
      sq: 4,
      food_eaten: 0,
      cost_wood: 20,
      cost_iron: 20,
      cost_gold: 400,
      allow_off: false
    }
  },
  {
    name: "Town Center",
    key: "town_center",
    attributes: {
      land: "P",
      workers: 0,
      sq: 25,
      food_eaten: 0,
      cost_wood: 100,
      cost_iron: 40,
      cost_gold: 2500,
      allow_off: false,
      max_units: 10,
      people: 100,
      supplies: 1000,
      max_explorers: 6,
      food_per_explorer: 5,
      max_local_trades: 100
    }
  },
  {
    name: "Market",
    key: "market",
    attributes: {
      land: "P",
      workers: 6,
      sq: 4,
      food_eaten: 0,
      cost_wood: 20,
      cost_iron: 2,
      cost_gold: 250,
      allow_off: false,
      max_trades: 50
    }
  },
  {
    name: "Warehouse",
    key: "warehouse",
    attributes: {
      land: "P",
      workers: 4,
      sq: 2,
      food_eaten: 0,
      cost_wood: 15,
      cost_iron: 0,
      cost_gold: 100,
      allow_off: false,
      supplies: 2500
    }
  },
  {
    name: "Stable",
    key: "stable",
    attributes: {
      land: "P",
      workers: 12,
      sq: 4,
      food_eaten: 0,
      cost_wood: 10,
      cost_iron: 2,
      cost_gold: 200,
      allow_off: true,
      production: 1,
      food_need: 100,
      production_name: "horses"
    }
  },
  {
    name: "Mage Tower",
    key: "mage_tower",
    attributes: {
      land: "P",
      workers: 20,
      sq: 10,
      food_eaten: 0,
      cost_wood: 50,
      cost_iron: 50,
      cost_gold: 2000,
      allow_off: true,
      production: 1,
      gold_need: 100,
      production_name: "research_points"
    }
  },
  {
    name: "Winery",
    key: "winery",
    attributes: {
      land: "P",
      workers: 12,
      sq: 6,
      food_eaten: 0,
      cost_wood: 12,
      cost_iron: 4,
      cost_gold: 1000,
      allow_off: true,
      production: 1,
      gold_need: 10,
      production_name: "wine"
    }
  }
]

buildings_data.each do |building_data|
  Building.find_or_create_by!(key: building_data[:key]) do |building|
    building.name = building_data[:name]
    building.attributes = building_data[:attributes]
  end
end 