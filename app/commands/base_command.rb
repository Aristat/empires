class BaseCommand
  attr_reader :errors

  def initialize
    @errors = []
  end

  def call
  end

  def success?
    errors.blank?
  end

  def failed?
    errors.present?
  end
end
