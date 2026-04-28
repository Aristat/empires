# frozen_string_literal: true

require "mock_redis"

RSpec.describe RedisLockService do
  let(:redis) { MockRedis.new }
  let(:key)   { "lock:test:#{SecureRandom.hex(4)}" }

  def service(timeout: 30)
    described_class.new(key: key, timeout: timeout, redis: redis)
  end

  # ─── call_without_lock ────────────────────────────────────────────────────

  describe "#call_without_lock" do
    context "when the lock is free" do
      it "yields and returns the block value" do
        result = service.call_without_lock { 42 }
        expect(result).to eq(42)
      end

      it "sets the Redis key with the correct TTL before yielding" do
        service(timeout: 30).call_without_lock do
          expect(redis.pttl(key)).to be_between(1, 30_000)
        end
      end

      it "deletes the Redis key after the block completes" do
        service.call_without_lock { :done }
        expect(redis.exists?(key)).to be false
      end
    end

    context "when the lock is already held" do
      before { redis.set(key, "other-token", nx: true, px: 30_000) }

      it "returns false without yielding" do
        yielded = false
        result  = service.call_without_lock { yielded = true }

        expect(result).to be false
        expect(yielded).to be false
      end

      it "does not delete the existing lock" do
        service.call_without_lock { nil }
        expect(redis.exists?(key)).to be true
      end

      it "returns false in under 5 ms" do
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        service.call_without_lock { nil }
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started

        expect(elapsed).to be < 0.005
      end
    end

    context "when the block raises" do
      it "releases the lock and re-raises the exception" do
        expect {
          service.call_without_lock { raise "boom" }
        }.to raise_error("boom")

        expect(redis.exists?(key)).to be false
      end
    end
  end

  # ─── call_with_lock ───────────────────────────────────────────────────────

  describe "#call_with_lock" do
    context "when the lock is free" do
      it "yields and returns the block value" do
        result = service.call_with_lock(timeout: 1) { :ok }
        expect(result).to eq(:ok)
      end

      it "deletes the Redis key after the block completes" do
        service.call_with_lock(timeout: 1) { :done }
        expect(redis.exists?(key)).to be false
      end
    end

    context "when the lock is held and never freed" do
      before { redis.set(key, "other-token", nx: true, px: 30_000) }

      it "returns false after the timeout elapses" do
        result = service(timeout: 0.12).call_with_lock { :never }
        expect(result).to be false
      end

      it "respects per-call timeout over the constructor default" do
        svc = described_class.new(key: key, timeout: 10, redis: redis)
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        svc.call_with_lock(timeout: 0.12) { :never }
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started

        expect(elapsed).to be < 1.0
      end

      it "does not busy-loop — polls at ~50 ms intervals" do
        call_count = 0
        allow(redis).to receive(:set).and_wrap_original do |m, *args, **kwargs|
          call_count += 1
          m.call(*args, **kwargs)
        end

        service(timeout: 0.15).call_with_lock { nil }

        # 0.15 s / 0.05 s poll = ~3 attempts; allow a small margin
        expect(call_count).to be <= 5
      end
    end

    context "when the lock becomes free before the timeout" do
      it "acquires the lock and yields" do
        redis.set(key, "other-token", nx: true, px: 30_000)
        Thread.new { sleep 0.08; redis.del(key) }

        result = service.call_with_lock(timeout: 1) { :acquired }
        expect(result).to eq(:acquired)
      end
    end

    context "when the block raises" do
      it "releases the lock and re-raises" do
        expect {
          service.call_with_lock(timeout: 1) { raise "oops" }
        }.to raise_error("oops")

        expect(redis.exists?(key)).to be false
      end
    end

    context "when timeout is set on the constructor and not overridden" do
      it "uses the constructor timeout" do
        redis.set(key, "other-token", nx: true, px: 30_000)
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        described_class.new(key: key, timeout: 0.12, redis: redis).call_with_lock { nil }
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started

        expect(elapsed).to be_between(0.08, 1.0)
      end
    end
  end

  # ─── Token safety ─────────────────────────────────────────────────────────

  describe "token safety" do
    it "does not allow a foreign token to release the lock" do
      svc1 = described_class.new(key: key, redis: redis)
      svc1.send(:acquire)

      svc2 = described_class.new(key: key, redis: redis)
      svc2.instance_variable_set(:@token, "wrong-token")
      svc2.send(:release)

      expect(redis.exists?(key)).to be true
    end
  end

  # ─── Timeout used as Redis TTL ────────────────────────────────────────────

  describe "timeout as Redis TTL" do
    it "sets the key TTL from the timeout parameter" do
      service(timeout: 15).call_without_lock do
        expect(redis.pttl(key)).to be_between(1, 15_000)
      end
    end
  end
end
