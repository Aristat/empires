# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: attack_queues
#
#  id              :bigint           not null, primary key
#  attack_status   :integer          not null
#  attack_type     :integer          not null
#  cost_food       :integer
#  cost_gold       :integer
#  cost_iron       :integer
#  cost_wine       :integer
#  cost_wood       :integer
#  soldiers        :jsonb            not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  game_id         :bigint           not null
#  to_user_game_id :bigint
#  user_game_id    :bigint           not null
#
# Indexes
#
#  index_attack_queues_on_game_id          (game_id)
#  index_attack_queues_on_to_user_game_id  (to_user_game_id)
#  index_attack_queues_on_user_game_id     (user_game_id)
#
# Foreign Keys
#
#  fk_rails_...  (to_user_game_id => user_games.id)
#  fk_rails_...  (user_game_id => user_games.id)
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class AttackQueue < ApplicationRecord
  belongs_to :game
  belongs_to :user_game
  belongs_to :to_user_game, class_name: 'UserGame', optional: true

  enum :attack_status, {
    preparing: 0,
    on_their_way: 1,
    almost_there: 2,
    done_fighting: 3,
    returning: 4,
    almost_home: 5
  }, prefix: true
  enum :attack_type, {
    army_conquer: 0,
    army_raid: 1,
    army_rob: 2,
    army_slaughter: 3,
    catapult_army_and_towers: 4,
    catapult_population: 5,
    catapult_buildings: 6,
    thief_steal_army_information: 7,
    thief_steal_building_information: 8,
    thief_steal_research_information: 9,
    thief_steal_goods: 10,
    thief_poison_water: 11,
    thief_set_fire: 12
  }, prefix: true

  store_accessor :soldiers, *UserGame::SOLDIERS.keys, suffix: true

  UserGame::SOLDIERS.keys.each do |status|
    define_method("#{status}_soldiers") do
      value = super()
      value.to_i
    end

    define_method("#{status}_soldiers=") do |value|
      super(value.to_i)
    end
  end

  def can_cancel?
    attack_status_preparing? || attack_status_on_their_way? || attack_status_almost_there?
  end

  def set_default_settings
    UserGame::SOLDIERS.each do |key, default|
      self.send("#{key}_soldiers=", default)
    end
  end
end
