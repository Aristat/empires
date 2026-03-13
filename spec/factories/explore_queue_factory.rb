# frozen_string_literal: true

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
