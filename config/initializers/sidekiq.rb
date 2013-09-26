if Rails.env.production?
  REDIS_CONFIG = {
    url: "redis://:#{ENV['REDIS_PASSWORD']}@#{ENV['OPENSHIFT_REDIS_HOST']}:#{ENV['OPENSHIFT_REDIS_PORT']}"
  }

  Sidekiq.configure_server do |config|
    config.redis = REDIS_CONFIG
  end

  Sidekiq.configure_client do |config|
    config.redis = REDIS_CONFIG
  end
end