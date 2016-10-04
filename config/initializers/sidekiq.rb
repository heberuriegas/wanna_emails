if Rails.env.production?

  if ENV['REDIS_PASSWORD'].present?
    REDIS_CONFIG = {
      url: "redis://:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}"
    }
  else
    REDIS_CONFIG = {
      url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}"
    }
  end

  Sidekiq.configure_server do |config|
    config.redis = REDIS_CONFIG
  end

  Sidekiq.configure_client do |config|
    config.redis = REDIS_CONFIG
  end
end
