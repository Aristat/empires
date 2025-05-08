# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: explore_queues
#
#  id           :bigint           not null, primary key
#  f_land       :integer
#  food         :integer
#  horses       :integer
#  m_land       :integer
#  p_land       :integer
#  people       :integer
#  seek_land    :integer
#  turn         :integer
#  turns_used   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_game_id :bigint           not null
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
end
