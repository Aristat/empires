# frozen_string_literal: true

require "mock_redis"

RSpec.configure do |config|
  config.before(:each) do
    mock = MockRedis.new
    stub_const("REDIS_LOCK_CLIENT", mock)
  end
end
