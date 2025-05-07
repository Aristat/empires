class ExampleCommand < BaseCommand
  def call
    Rails.logger.info('ExampleCommand executed')
  end
end
