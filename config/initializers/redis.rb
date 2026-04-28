REDIS_LOCK_CLIENT = Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'))
