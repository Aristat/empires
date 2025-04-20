class Building < ApplicationRecord
  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  store_accessor :settings, 
    :land, :workers, :squares, :food_eaten, :cost_wood, :cost_iron, :cost_gold,
    :allow_off, :production, :production_name, :people, :max_units,
    :max_train, :need_gold, :wood_need, :iron_need, :num_builders,
    :mace_wood, :mace_iron, :supplies, :max_explorers, :food_per_explorer,
    :max_local_trades, :max_trades, :food_need, :gold_need
end
