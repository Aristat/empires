# frozen_string_literal: true

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
FactoryBot.define do
  factory :explore_queue do
    association :user_game
    people { 5 }
    horse_setting { :without_horses }
    seek_land { :all_land }
    food { 50 }
    horses { 0 }
    turn { 6 }
    turns_used { 0 }
  end
end
