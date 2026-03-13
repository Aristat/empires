# frozen_string_literal: true

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
