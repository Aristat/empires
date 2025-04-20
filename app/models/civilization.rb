class Civilization < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  store_accessor :settings, :special_unit, :buildings
end
