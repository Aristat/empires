# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: attack_logs
#
#  id             :bigint           not null, primary key
#  attack_type    :integer          not null
#  attacker_wins  :boolean          not null
#  battle_details :string           not null
#  casualties     :jsonb            not null
#  message        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  attacker_id    :bigint
#  defender_id    :bigint
#
# Indexes
#
#  index_attack_logs_on_attacker_id  (attacker_id)
#  index_attack_logs_on_defender_id  (defender_id)
#
# Foreign Keys
#
#  fk_rails_...  (attacker_id => user_games.id)
#  fk_rails_...  (defender_id => user_games.id)
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class AttackLog < ApplicationRecord
  belongs_to :attacker, class_name: 'UserGame'
  belongs_to :defender, class_name: 'UserGame'

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

  validates :attacker_wins, inclusion: { in: [true, false] }
end
