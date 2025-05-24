# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: user_games
#
#  id                  :bigint           not null, primary key
#  auto_buy_food       :integer          default(0), not null
#  auto_buy_iron       :integer          default(0), not null
#  auto_buy_tools      :integer          default(0), not null
#  auto_buy_wood       :integer          default(0), not null
#  auto_sell_food      :integer          default(0), not null
#  auto_sell_iron      :integer          default(0), not null
#  auto_sell_tools     :integer          default(0), not null
#  auto_sell_wood      :integer          default(0), not null
#  bow_weaponsmith     :integer          default(0), not null
#  bows                :integer          default(0), not null
#  current_turns       :integer          default(0), not null
#  f_land              :integer          default(0), not null
#  farm                :integer          default(0), not null
#  farm_status         :integer          default(100), not null
#  food                :integer          default(0), not null
#  food_ratio          :integer          default(0), not null
#  fort                :integer          default(0), not null
#  gold                :integer          default(0), not null
#  gold_mine           :integer          default(0), not null
#  gold_mine_status    :integer          default(100), not null
#  horses              :integer          default(0), not null
#  house               :integer          default(0), not null
#  hunter              :integer          default(0), not null
#  hunter_status       :integer          default(100), not null
#  iron                :integer          default(0), not null
#  iron_mine           :integer          default(0), not null
#  iron_mine_status    :integer          default(100), not null
#  last_message        :jsonb            not null
#  last_turn_at        :datetime
#  m_land              :integer          default(0), not null
#  mace_weaponsmith    :integer          default(0), not null
#  maces               :integer          default(0), not null
#  mage_tower          :integer          default(0), not null
#  mage_tower_status   :integer          default(100), not null
#  market              :integer          default(0), not null
#  p_land              :integer          default(0), not null
#  people              :integer          default(0), not null
#  research_points     :integer          default(0), not null
#  researches          :jsonb            not null
#  score               :bigint           default(0), not null
#  stable              :integer          default(0), not null
#  stable_status       :integer          default(100), not null
#  sword_weaponsmith   :integer          default(0), not null
#  swords              :integer          default(0), not null
#  tool_maker          :integer          default(0), not null
#  tool_maker_status   :integer          default(100), not null
#  tools               :integer          default(0), not null
#  tower               :integer          default(0), not null
#  town_center         :integer          default(0), not null
#  trades_this_turn    :integer          default(0), not null
#  turn                :integer          default(0), not null
#  wall                :integer          default(0), not null
#  wall_build_per_turn :integer          default(0), not null
#  warehouse           :integer          default(0), not null
#  weaponsmith         :integer          default(0), not null
#  weaponsmith_status  :integer          default(100), not null
#  wine                :integer          default(0), not null
#  winery              :integer          default(0), not null
#  winery_status       :integer          default(100), not null
#  wood                :integer          default(0), not null
#  wood_cutter         :integer          default(0), not null
#  wood_cutter_status  :integer          default(100), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  civilization_id     :bigint           not null
#  game_id             :bigint           not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_user_games_on_civilization_id  (civilization_id)
#  index_user_games_on_game_id          (game_id)
#  index_user_games_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (civilization_id => civilizations.id)
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class UserGame < ApplicationRecord
  RESEARCHES = {
    attack_points: 0,
    defense_points: 0,
    thieves_strength: 0,
    military_losses: 0,
    food_production: 0,
    mine_production: 0,
    weapons_tools_production: 0,
    space_effectiveness: 0,
    markets_output: 0,
    explorers: 0,
    catapults_strength: 0,
    wood_production: 0
  }.freeze

  belongs_to :user
  belongs_to :game
  belongs_to :civilization

  has_many :build_queues, dependent: :destroy
  has_many :explore_queues, dependent: :destroy

  store_accessor :researches, *RESEARCHES.keys, suffix: true

  validates :food_ratio, presence: true, numericality: { greater_than_or_equal_to: -2, less_than_or_equal_to: 4 }
  validates :hunter_status, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :farm_status, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :wood_cutter_status, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :gold_mine_status, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :iron_mine_status, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :tool_maker_status, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :winery_status, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :weaponsmith_status, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :stable_status, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :mage_tower_status, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def set_default_settings
    RESEARCHES.each do |key, default|
      self.send("#{key}_researches=", default) if self.send("#{key}_researches").nil?
    end
  end
end
