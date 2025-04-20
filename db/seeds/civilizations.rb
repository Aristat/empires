civilizations_data = [
  {
    name: "Vikings",
    key: "vikings",
    settings: {
      special_unit: {
        name: "Berserker",
        attack_points: 25,
        defense_points: 5,
        train_swords: 1,
        train_horses: 1,
        train_bows: 1,
        take_land: 0.30
      },
      buildings: {
        wood_cutter: {
          squares: 3,
          production: 5
        },
        hunter: {
          production: 5
        },
        farmer: {
          production: 6
        },
        house: {
          people: 75
        },
        iron_mine: {
          production: 2
        },
        stable: {
          squares: 6,
          food_need: 150
        },
        warehouse: {
          supplies: 1250
        },
        winery: {
          squares: 8
        }
      },
      game: {
        people_burn_one_wood: 125
      }
    }
  },
  {
    name: "Franks",
    key: "franks",
    settings: {
      special_unit: {
        name: "Paladin",
        attack_points: 5,
        defense_points: 30,
        train_swords: 3,
        train_horses: 1,
        take_land: 0.30
      },
      buildings: {
        farmer: {
          squares: 2
        },
        tool_maker: {
          num_builders: 10
        },
        tower: {
          squares: 3,
          cost_wood: 10,
          cost_iron: 10
        },
        fort: {
          max_units: 12
        },
        town_center: {
          max_explorers: 7
        },
        mage_tower: {
          squares: 12,
          workers: 15
        }
      },
      game: {
        pop_increase_modifier: 0.80,
        extra_food_per_land: 840
      }
    }
  },
  {
    name: "Japanese",
    key: "japanese",
    settings: {
      special_unit: {
        name: "Samurai",
        attack_points: 20,
        defense_points: 10,
        train_swords: 2,
        take_land: 0.50
      },
      buildings: {
        wood_cutter: {
          squares: 5
        },
        hunter: {
          production: 2
        },
        farmer: {
          production: 10
        },
        house: {
          people: 120
        },
        market: {
          max_trades: 40
        },
        stable: {
          squares: 8
        },
        town_center: {
          squares: 20
        },
        mage_tower: {
          production: 1.5
        }
      }
    }
  },
  {
    name: "Byzantines",
    key: "byzantines",
    settings: {
      special_unit: {
        name: "Cataphract",
        attack_points: 15,
        defense_points: 15,
        train_swords: 1,
        train_horses: 1,
        train_bows: 1,
        take_land: 0.20
      },
      buildings: {
        iron_mine: {
          squares: 3
        },
        tool_maker: {
          num_builders: 5
        },
        gold_mine: {
          squares: 2,
          production: 200
        },
        market: {
          max_trades: 100
        },
        warehouse: {
          supplies: 5000
        },
        mage_tower: {
          squares: 8
        }
      },
      game: {
        people_eat_one_food: 60
      }
    }
  },
  {
    name: "Mongols",
    key: "mongols",
    settings: {
      special_unit: {
        name: "Horse Archer",
        attack_points: 20,
        defense_points: 5,
        train_horses: 1,
        train_bows: 1,
        take_land: 0.15,
        turns: 10,
        train_gold: 100,
        gold_per_turn: 5
      },
      buildings: {
        farmer: {
          production: 6
        },
        hunter: {
          production: 4
        },
        fort: {
          squares: 8,
          max_units: 20
        },
        tool_maker: {
          production: 2,
          num_builders: 8
        },
        weaponsmith: {
          production: 2
        },
        town_center: {
          max_explorers: 5
        },
        mage_tower: {
          gold_need: 200
        }
      },
      game: {
        people_eat_one_food: 50,
        pop_increase_modifier: 1.4,
        extra_food_per_land: 720
      }
    }
  },
  {
    name: "Incas",
    key: "incas",
    settings: {
      special_unit: {
        name: "Shaman",
        attack_points: 1,
        defense_points: 1,
        train_horses: 0,
        train_bows: 0,
        take_land: 5,
        turns: 14,
        train_gold: 5000,
        gold_per_turn: 50
      },
      buildings: {
        iron_mine: {
          squares: 3
        },
        town_center: {
          squares: 36,
          people: 100,
          supplies: 5000
        },
        market: {
          max_trades: 100
        },
        mage_tower: {
          gold_need: 25
        }
      }
    }
  },
  {
    name: "Chinese",
    key: "chinese",
    settings: {
      special_unit: {
        name: "Kung Fu Warrior",
        attack_points: 15,
        defense_points: 15,
        train_horses: 0,
        train_bows: 0,
        take_land: 0.5,
        turns: 10
      },
      buildings: {
        tower: {
          squares: 3
        },
        weaponsmith: {
          wood_need: 20,
          iron_need: 20
        },
        house: {
          squares: 4
        },
        winery: {
          squares: 8
        }
      },
      game: {
        pop_increase_modifier: 2,
        wall_use_gold: 75,
        wall_use_iron: 1,
        wall_use_wood: 8,
        wall_use_wine: 3
      }
    }
  },
  {
    name: "Barbarians",
    key: "barbarians",
    settings: {
      special_unit: {
        name: "Giant Warrior",
        attack_points: 50,
        defense_points: 1,
        train_horses: 1,
        train_swords: 3,
        take_land: 1,
        turns: 4,
        food_eaten: 4
      }
    }
  }
]

civilizations_data.each do |civilization_data|
  Civilization.find_or_create_by!(key: civilization_data[:key]) do |civilization|
    civilization.name = civilization_data[:name]
    civilization.settings = civilization_data[:settings]
  end
  puts "Created/Updated civilization: #{civilization_data[:name]}"
end 