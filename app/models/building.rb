# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: buildings
#
#  id         :bigint           not null, primary key
#  key        :string           not null
#  name       :string           not null
#  position   :integer          default(0), not null
#  settings   :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_buildings_on_key  (key) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class Building < ApplicationRecord
  DEFAULT_NUM_BUILDERS = 3

  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  store_accessor :settings,
                 # resources for build
                 :land,
                 :workers,
                 :squares, # squares for land
                 :food_eaten,
                 :cost_wood,
                 :cost_iron,
                 :cost_gold,
                 # production resources
                 :allow_off,
                 :production,
                 :production_key,
                 :people, # increase people
                 :custom_settings # custom settings for building
end
