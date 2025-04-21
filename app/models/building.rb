class Building < ApplicationRecord
  DEFAULT_NUM_BUILDERS = 3

  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  # custom settings are
  # cost_food_per_turn
  # cost_gold_per_turn
  # cost_wood_per_turn
  # cost_iron_per_turn
  # number_of_builders
  # resources_limit_increase
  # max_explorer
  # food_per_explorer
  store_accessor :settings,
                 # resources for build
                 :land,
                 :workers,
                 :squares, # squares for land
                 :food_eaten,
                 :cost_wood,
                 :cost_iron,
                 :cost_gold,
                 # production resources
                 :allow_off,
                 :production,
                 :production_key,
                 :people, # increase people
                 :custom_settings # custom settings for building
end
