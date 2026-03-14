# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: user_games
#
#  id               :bigint           not null, primary key
#  buildings_statuses :jsonb           not null
#  current_turns    :integer          default(0), not null
#  f_land           :integer          default(0), not null
#  farm             :integer          default(0), not null
#  food             :integer          default(0), not null
#  food_ratio       :integer          default(0), not null
#  gold             :integer          default(0), not null
#  house            :integer          default(0), not null
#  hunter           :integer          default(0), not null
#  iron             :integer          default(0), not null
#  last_message     :jsonb            not null
#  m_land           :integer          default(0), not null
#  p_land           :integer          default(0), not null
#  people           :integer          default(0), not null
#  researches       :jsonb            not null
#  score            :bigint           default(0), not null
#  soldiers         :jsonb            not null
#  tools            :integer          default(0), not null
#  trades           :jsonb            not null
#  turn             :integer          default(0), not null
#  wood             :integer          default(0), not null
#  civilization_id  :bigint           not null
#  game_id          :bigint           not null
#  user_id          :bigint           not null
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
FactoryBot.define do
  factory :user_game do
    association :user
    association :game
    civilization { game.civilizations.first }

    food_ratio          { 1 }
    food                { 2500 }
    wood                { 1000 }
    iron                { 1000 }
    gold                { 100_000 }
    tools               { 250 }
    people              { 3000 }
    f_land              { 1000 }
    m_land              { 500 }
    p_land              { 2500 }
    hunter              { 50 }
    farm                { 20 }
    wood_cutter         { 20 }
    gold_mine           { 10 }
    iron_mine           { 20 }
    tool_maker          { 10 }
    house               { 50 }
    tower               { 10 }
    town_center         { 10 }
    market              { 10 }
    wall_build_per_turn { 0 }
    last_turn_at        { Time.current }
    current_turns       { 100 }
    last_message        { [] }
    buildings_statuses  { UserGame::BUILDING_STATUSES.transform_values(&:to_s) }
    researches          { UserGame::RESEARCHES.transform_values(&:to_s) }
    trades              { UserGame::TRADES.transform_values(&:to_s) }
    soldiers            { UserGame::SOLDIERS.transform_values(&:to_s) }
  end
end
