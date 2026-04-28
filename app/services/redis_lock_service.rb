# frozen_string_literal: true

class RedisLockService
  POLL_INTERVAL = 0.05 # seconds

  def self.with_locks(*keys, timeout: 30, redis: REDIS_LOCK_CLIENT, &block)
    key, *rest = keys.map(&:to_s).sort
    return yield if key.nil?

    new(key: key, timeout: timeout, redis: redis).call_without_lock do
      rest.empty? ? yield : with_locks(*rest, timeout: timeout, redis: redis, &block)
    end
  end

  def initialize(key:, timeout: 30, redis: REDIS_LOCK_CLIENT)
    @key     = key
    @timeout = timeout
    @redis   = redis
    @token   = nil
  end

  def call_without_lock(&block)
    return false unless acquire

    run_with_ensure(&block)
  end

  def call_with_lock(timeout: @timeout, &block)
    deadline = Time.current + timeout

    loop do
      return run_with_ensure(&block) if acquire
      return false if Time.current >= deadline

      sleep POLL_INTERVAL
    end
  end

  private

  def acquire
    @token = SecureRandom.uuid
    @redis.set(@key, @token, nx: true, px: (@timeout * 1000).to_i)
  end

  def release
    @redis.del(@key) if @redis.get(@key) == @token
  end

  def run_with_ensure
    yield
  ensure
    release
  end
end
