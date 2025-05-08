# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: user_games
#
#  id                  :bigint           not null, primary key
#  archers             :integer
#  current_turns       :integer
#  f_land              :integer
#  farm                :integer
#  farm_status         :integer          default(100)
#  food                :integer
#  food_ratio          :integer
#  fort                :integer
#  gold                :integer
#  gold_mine           :integer
#  gold_mine_status    :integer          default(100)
#  horseman            :integer
#  horses              :integer
#  house               :integer
#  hunter              :integer
#  hunter_status       :integer          default(100)
#  iron                :integer
#  iron_mine           :integer
#  iron_mine_status    :integer          default(100)
#  last_message        :jsonb            not null
#  last_turn_at        :datetime
#  m_land              :integer
#  mage_tower          :integer
#  mage_tower_status   :integer          default(100)
#  market              :integer
#  p_land              :integer
#  people              :integer
#  score               :bigint
#  stable              :integer
#  stable_status       :integer          default(100)
#  swordsman           :integer
#  tool_maker          :integer
#  tool_maker_status   :integer          default(100)
#  tools               :integer
#  tower               :integer
#  town_center         :integer
#  turn                :integer
#  wall                :integer
#  wall_build_per_turn :integer
#  warehouse           :integer
#  weaponsmith         :integer
#  weaponsmith_status  :integer          default(100)
#  wine                :integer
#  winery              :integer
#  winery_status       :integer          default(100)
#  wood                :integer
#  wood_cutter         :integer
#  wood_cutter_status  :integer          default(100)
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
    belongs_to :user
    belongs_to :game
    belongs_to :civilization

    has_many :build_queues, dependent: :destroy
    has_many :explore_queues, dependent: :destroy
end
