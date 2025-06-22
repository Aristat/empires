# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: user_games
#
#  id                  :bigint           not null, primary key
#  bow_weaponsmith     :integer          default(0), not null
#  bows                :integer          default(0), not null
#  buildings_statuses  :jsonb            not null
#  current_research    :integer
#  current_turns       :integer          default(0), not null
#  f_land              :integer          default(0), not null
#  farm                :integer          default(0), not null
#  food                :integer          default(0), not null
#  food_ratio          :integer          default(0), not null
#  fort                :integer          default(0), not null
#  gold                :integer          default(0), not null
#  gold_mine           :integer          default(0), not null
#  horses              :integer          default(0), not null
#  house               :integer          default(0), not null
#  hunter              :integer          default(0), not null
#  iron                :integer          default(0), not null
#  iron_mine           :integer          default(0), not null
#  last_message        :jsonb            not null
#  last_turn_at        :datetime
#  m_land              :integer          default(0), not null
#  mace_weaponsmith    :integer          default(0), not null
#  maces               :integer          default(0), not null
#  mage_tower          :integer          default(0), not null
#  market              :integer          default(0), not null
#  p_land              :integer          default(0), not null
#  people              :integer          default(0), not null
#  research_points     :integer          default(0), not null
#  researches          :jsonb            not null
#  score               :bigint           default(0), not null
#  soldiers            :jsonb            not null
#  stable              :integer          default(0), not null
#  sword_weaponsmith   :integer          default(0), not null
#  swords              :integer          default(0), not null
#  tool_maker          :integer          default(0), not null
#  tools               :integer          default(0), not null
#  tower               :integer          default(0), not null
#  town_center         :integer          default(0), not null
#  trades              :jsonb            not null
#  trades_this_turn    :integer          default(0), not null
#  turn                :integer          default(0), not null
#  wall                :integer          default(0), not null
#  wall_build_per_turn :integer          default(0), not null
#  warehouse           :integer          default(0), not null
#  weaponsmith         :integer          default(0), not null
#  wine                :integer          default(0), not null
#  winery              :integer          default(0), not null
#  wood                :integer          default(0), not null
#  wood_cutter         :integer          default(0), not null
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
  BUILDING_STATUSES = {
    hunter_status: 100,
    farm_status: 100,
    wood_cutter_status: 100,
    gold_mine_status: 100,
    iron_mine_status: 100,
    tool_maker_status: 100,
    winery_status: 100,
    weaponsmith_status: 100,
    stable_status: 100,
    mage_tower_status: 100
  }.freeze

  MARKETS_OUTPUT_RESEARCHES_MULTIPLIER = 10
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

  TRADES = {
    auto_buy_wood: 0,
    auto_buy_food: 0,
    auto_buy_iron: 0,
    auto_buy_tools: 0,
    auto_sell_wood: 0,
    auto_sell_food: 0,
    auto_sell_iron: 0,
    auto_sell_tools: 0
  }.freeze

  SOLDIERS = {
    unique_unit: 0,
    archer: 0,
    swordsman: 0,
    horseman: 0,
    catapult: 0,
    macemen: 0,
    trained_peasant: 0,
    thieve: 0
  }.freeze

  GLOBAL_TRADE_RESOURCES = %w[wood food iron tools swords bows maces horses wine].freeze

  belongs_to :user
  belongs_to :game
  belongs_to :civilization

  has_many :build_queues, dependent: :destroy
  has_many :explore_queues, dependent: :destroy
  has_many :train_queues, dependent: :destroy
  has_many :transfer_queues, dependent: :destroy
  has_many :attack_queues, dependent: :destroy

  # TODO! Add more researches like
  # Conquered land
  # Army Upkeep cost
  # Army Training cost
  # Wine production
  # Horses production
  # Fort space
  enum :current_research, {
    attack_points: 0,
    defense_points: 1,
    thieves_strength: 2,
    military_losses: 3,
    food_production: 4,
    mine_production: 5,
    weapons_tools_production: 6,
    space_effectiveness: 7,
    markets_output: 8,
    explorers: 9,
    catapults_strength: 10,
    wood_production: 11
  }, prefix: true

  store_accessor :buildings_statuses, *BUILDING_STATUSES.keys, suffix: true
  store_accessor :researches, *RESEARCHES.keys, suffix: true
  store_accessor :trades, *TRADES.keys, suffix: true
  store_accessor :soldiers, *SOLDIERS.keys, suffix: true

  BUILDING_STATUSES.keys.each do |status|
    define_method("#{status}_buildings_statuses") do
      value = super()
      value.to_i
    end

    define_method("#{status}_buildings_statuses=") do |value|
      super(value.to_i)
    end
  end

  RESEARCHES.keys.each do |status|
    define_method("#{status}_researches") do
      value = super()
      value.to_i
    end

    define_method("#{status}_researches=") do |value|
      super(value.to_i)
    end
  end

  TRADES.keys.each do |status|
    define_method("#{status}_trades") do
      value = super()
      value.to_i
    end

    define_method("#{status}_trades=") do |value|
      super(value.to_i)
    end
  end

  SOLDIERS.keys.each do |status|
    define_method("#{status}_soldiers") do
      value = super()
      value.to_i
    end

    define_method("#{status}_soldiers=") do |value|
      super(value.to_i)
    end
  end

  validates :food_ratio, presence: true, numericality: { greater_than_or_equal_to: -2, less_than_or_equal_to: 4 }
  validates :hunter_status_buildings_statuses, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :farm_status_buildings_statuses, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :wood_cutter_status_buildings_statuses, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :gold_mine_status_buildings_statuses, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :iron_mine_status_buildings_statuses, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :tool_maker_status_buildings_statuses, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :winery_status_buildings_statuses, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :weaponsmith_status_buildings_statuses, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :stable_status_buildings_statuses, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :mage_tower_status_buildings_statuses, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  validates :military_losses_researches, presence: true, numericality: { less_than_or_equal_to: 50 }

  def set_default_settings
    BUILDING_STATUSES.each do |key, default|
      self.send("#{key}_buildings_statuses=", default)
    end

    RESEARCHES.each do |key, default|
      self.send("#{key}_researches=", default)
    end

    TRADES.each do |key, default|
      self.send("#{key}_trades=", default)
    end

    SOLDIERS.each do |key, default|
      self.send("#{key}_soldiers=", default)
    end
  end
end
