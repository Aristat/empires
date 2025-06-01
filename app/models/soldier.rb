# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: soldiers
#
#  id         :bigint           not null, primary key
#  key        :string           not null
#  name       :string           not null
#  position   :integer          default(0), not null
#  settings   :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#
# Indexes
#
#  index_soldiers_on_game_id  (game_id)
#  index_soldiers_on_key      (key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class Soldier < ApplicationRecord
  belongs_to :game

  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  store_accessor :settings,
                 :turns,
                 :attack_points,
                 :defense_points,
                 :gold_per_turn,
                 :train_gold,
                 :train_wood,
                 :train_iron,
                 :train_swords,
                 :train_bows,
                 :train_maces,
                 :train_horses,
                 :take_land,
                 :food_eaten
end
