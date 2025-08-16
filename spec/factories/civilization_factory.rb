# frozen_string_literal: true

FactoryBot.define do
  factory :civilization do
    game
    name { Faker::Lorem.characters }
    key { 'vikings' }
  end
end
