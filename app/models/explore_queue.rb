# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: explore_queues
#
#  id            :bigint           not null, primary key
#  f_land        :integer          default(0), not null
#  food          :integer          default(0), not null
#  horse_setting :integer          not null
#  horses        :integer          not null
#  m_land        :integer          default(0), not null
#  p_land        :integer          default(0), not null
#  people        :integer          not null
#  seek_land     :integer          not null
#  turn          :integer          not null
#  turns_used    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_game_id  :bigint           not null
#
# Indexes
#
#  index_explore_queues_on_user_game_id  (user_game_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_game_id => user_games.id)
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class ExploreQueue < ApplicationRecord
  belongs_to :user_game

  enum :horse_setting, {
    without_horses: 0,
    one_horse: 1,
    two_horses: 2,
    three_horses: 3
  }, prefix: true

  enum :seek_land, {
    all_land: 0,
    mountain_land: 1,
    forest_land: 2,
    plain_land: 3
  }, prefix: true

  validates :people, presence: true, numericality: { greater_than_or_equal_to: 4 }
end
