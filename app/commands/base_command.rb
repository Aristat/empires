class BaseCommand
  attr_reader :messages, :errors

  def initialize
    @messages = []
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
