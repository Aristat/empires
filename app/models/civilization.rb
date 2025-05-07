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
#
# Indexes
#
#  index_civilizations_on_key  (key) UNIQUE
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class Civilization < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  store_accessor :settings, :special_unit, :buildings
end
