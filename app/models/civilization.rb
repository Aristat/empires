# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: civilizations
#
#  id          :bigint           not null, primary key
#  description :text
#  key         :string           not null
#  name        :string
#  settings    :jsonb            not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  game_id     :bigint           not null
#
# Indexes
#
#  index_civilizations_on_game_id  (game_id)
#  index_civilizations_on_key      (key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class Civilization < ApplicationRecord
  belongs_to :game

  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  store_accessor :settings, :special_unit, :buildings
end
