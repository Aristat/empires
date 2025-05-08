# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: build_queues
#
#  id            :bigint           not null, primary key
#  building_type :integer          not null
#  gold          :integer          default(0), not null
#  iron          :integer          default(0), not null
#  on_hold       :boolean          default(FALSE), not null
#  position      :integer          not null
#  quantity      :integer          default(0), not null
#  queue_type    :integer          not null
#  time_needed   :integer          default(0), not null
#  turn_added    :integer          default(0), not null
#  wood          :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_game_id  :bigint           not null
#
# Indexes
#
#  index_build_queues_on_user_game_id               (user_game_id)
#  index_build_queues_on_user_game_id_and_position  (user_game_id,position)
#
# Foreign Keys
#
#  fk_rails_...  (user_game_id => user_games.id)
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class BuildQueue < ApplicationRecord
  include StringKeyConcern

  MAX_BUILDING_QUANTITY_PER_ACTION = 10_000_000

  belongs_to :user_game

  acts_as_list scope: :user_game

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
end
