class BuildQueue < ApplicationRecord
  belongs_to :user_game

  validates :building_type, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :queue_type, presence: true, inclusion: { in: %w[build demolish] }
  validates :iron, :wood, :gold, :time_needed, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(on_hold: false) }
  scope :ordered, -> { order(position: :asc) }
  scope :for_turn, ->(turn) { where(turn_added: turn) }

  enum :queue_type, {
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

  def move_to_top
    transaction do
      # Shift all other items down
      user_game.build_queues.where("position < ?", position).update_all("position = position + 1")
      # Move this item to position 0
      update!(position: 0)
    end
  end

  def move_to_bottom
    transaction do
      max_position = user_game.build_queues.maximum(:position)
      user_game.build_queues.where("position > ?", position).update_all("position = position - 1")
      update!(position: max_position)
    end
  end
end
