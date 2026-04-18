# frozen_string_literal: true

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
FactoryBot.define do
  factory :build_queue do
    association :user_game
    building_type { :hunter }
    queue_type { :build }
    quantity { 1 }
    position { 1 }
    turn_added { 0 }
    time_needed { 4 }
    gold { 25 }
    wood { 4 }
    iron { 0 }

    trait :demolish do
      queue_type { :demolish }
      gold { 0 }
      wood { 0 }
      iron { 0 }
    end
  end
end
