Sentry.init do |config|
  config.dsn = Horizon.config.sentry_dsn if Horizon.config.sentry_dsn
end
