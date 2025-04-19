class Civilization < ApplicationRecord
  store_accessor :bonuses, :military, :construction, :research

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
