class BuildQueue < ApplicationRecord
  belongs_to :user_game

  validates :building_type, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :mission, presence: true, inclusion: { in: %w[build demolish] }
  validates :iron, :wood, :gold, :time_needed, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  enum :mission, {
    build: 0,
    demolish: 1
  }, prefix: true

  enum :building_type, {
    wood_cutter: 0,
    hunter: 1,
    farm: 2,
    gold_mine: 3,
    iron_mine: 4,
    tool_maker: 5,
    winery: 6,
    mage_tower: 7,
    weaponsmith: 8,
    fort: 9,
    tower: 10,
    town_center: 11,
    market: 12,
    warehouse: 13,
    stable: 14,
    house: 15
  }, prefix: true
end
