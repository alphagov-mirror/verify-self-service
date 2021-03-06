Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.transport_failure_callback = ->(event) { Rails.logger.error(event.to_s) }
  config.current_environment = ENV.fetch("SENTRY_ENV", "unspecified")
end
