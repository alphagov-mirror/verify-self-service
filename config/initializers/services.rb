require 'auth/cognito_chooser'
require 'auth/cognito_stub_client'

module SelfService
  def self.register_service(name:, client:)
    @services ||= {}

    @services[name] = client
  end

  def self.service(name)
    @services[name] || raise(ServiceNotRegisteredException.new(name))
  end

  def self.service_present?(name)
    self.service(name)
    true
  rescue SelfService::ServiceNotRegisteredException
    false
  end

  class ServiceNotRegisteredException < RuntimeError; end
end

def configuration(yaml_file_name)
  storage_yml = Pathname.new(Rails.root.join('config', yaml_file_name))
  erb = ERB.new(storage_yml.read)
  configuration = YAML.safe_load(erb.result) || {}
  configuration.deep_symbolize_keys
rescue Errno::ENOENT
  puts "Missing configuration file #{yaml_file_name} in config"
  {}
end

ENV['HUB_ENVIRONMENTS'].split(',').each do |hub_env|
  SelfService.register_service(
    name: "#{hub_env}_storage_client".to_sym,
    client: ActiveStorage::Service.configure(
      Rails.configuration.active_storage.service,
      configuration(hub_env == 'integration' ? 'integration_storage.yml' : 'storage.yml')
    )
  )
end


CognitoChooser.new
