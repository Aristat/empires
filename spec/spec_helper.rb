ENV['RAILS_ENV'] = 'test'

require File.expand_path('../config/environment', __dir__)

abort("The Rails environment is running in production mode!") unless Rails.env.test?

require 'spec_helper'
require 'rspec/rails'
require 'faker'

Rails.root.glob("spec/support/**/*.rb").each { |f| require f }

FactoryBot.find_definitions

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:suite) do
    WebMock.disable_net_connect!(allow_localhost: true)

    DatabaseCleaner.url_allowlist = [/@(pg|localhost):/] if ENV['DATABASE_URL'].present?
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
