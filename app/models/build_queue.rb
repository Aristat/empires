class BuildQueue < ApplicationRecord
  belongs_to :user_game

  validates :building_type, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :mission, presence: true, inclusion: { in: %w[build demolish] }
  validates :iron, :wood, :gold, :time_needed, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
