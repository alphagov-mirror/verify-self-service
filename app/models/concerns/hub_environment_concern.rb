module HubEnvironmentConcern
  extend ActiveSupport::Concern

  def hub_environment(environment, value)
    environment = to_symbol(environment)
    value = to_symbol(value)
    Rails.configuration.hub_environments.fetch(environment)[value]
  rescue KeyError
    Rails.logger.error("Failed to find #{value} for #{environment}")
    "#{environment}-#{value}"
  end

  def to_symbol(value)
    value.is_a?(Symbol) ? value : value.to_sym
  end
end
