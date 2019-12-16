require 'yaml'
require 'digest/md5'
require 'polling/cert_status_updater'
require 'api/hub_config_api'
class PublishServicesMetadataEvent < Event
  include HubEnvironmentConcern
  attr_reader :metadata
  data_attributes :event_id, :services_metadata, :environment
  validates_presence_of :event_id
  before_create :populate_data_attributes
  before_create :upload
  after_create_commit :poll_hub_config

  def populate_data_attributes
    @metadata = services_metadata
    assign_attributes(services_metadata: metadata)
  end

  def upload
    SelfService.service(:storage_client).put_object(
      bucket: hub_environment(environment, :bucket),
      key: FILES::CONFIG_METADATA,
      body: StringIO.new(metadata.to_json),
      server_side_encryption: 'AES256',
      acl: 'bucket-owner-full-control',
    )
  rescue Aws::S3::Errors::ServiceError
    Rails.logger.error("Failed to publish config metadata for event #{event_id}")
    raise ActiveRecord::Rollback
  end

private

  def poll_hub_config

    case Rails.env
    when 'development', 'test'
      poll
    when 'production'
      poll
    end
  end

  def poll
    scheduler = Polling::Scheduler.new
    certs_updater = CertStatusUpdater.new(HUB_CONFIG_API)
    certificates = Certificate.all_pollable(environment)
    certificates.each { |certificate|
      scheduler.mode(:every)
                .perform(-> { p "#{certificate} are being polled in #{Rails.env}" } )
                .until(scheduler.action_result.certificate.in_use_at.present?)
    }
  end

  def certificates_in_use_by_component_services?
    Certificate.all_pollable(environment).any?
  end

  def services_metadata
    Component.to_service_metadata(event_id, environment)
  end
end
