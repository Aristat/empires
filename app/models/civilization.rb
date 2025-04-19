class Civilization < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :bonuses, presence: true

  validate :validate_bonuses_schema

  private

  def validate_bonuses_schema
    return if bonuses.blank?

    unless bonuses.is_a?(Hash) &&
           bonuses.key?('military') &&
           bonuses.key?('construction') &&
           bonuses.key?('research') &&
           bonuses.values.all? { |v| v.is_a?(Numeric) }
      errors.add(:bonuses, 'must be a hash with military, construction, and research numeric values')
    end
  end
end 