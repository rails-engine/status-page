require 'redis/namespace'

module StatusPage
  module Services
    class RedisException < StandardError; end

    class Redis < Base
      class Configuration
        attr_accessor :url

        def initialize
          @url = "redis://127.0.0.1:3306/1"
        end
      end

      class << self
        def config_class
          Redis::Configuration
        end
      end

      def check!
        time = Time.now.to_s(:db)

        redis = ::Redis.new(url: config.url)
        redis.set(key, time)
        fetched = redis.get(key)

        raise "different values (now: #{time}, fetched: #{fetched})" if fetched != time
      rescue Exception => e
        raise RedisException.new(e.message)
      ensure
        redis.client.disconnect
      end

      private

      def key
        @key ||= ['status-redis', request.try(:remote_ip)].join(':')
      end
    end
  end
end
