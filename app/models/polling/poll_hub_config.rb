require 'polling/cert_status_updater'
require 'api/hub_config_api'

module PollHubConfig
  def update_pollable_certificates
    scheduler = Polling::Scheduler.new
    pollable_certificates.each do |certificate|
      poll(scheduler, certificate)
    end
  end

private

  def poll(scheduler, certificate)
    scheduler.mode(:every)
             .perform(-> { CertStatusUpdater.new.update_hub_usage_status_for_cert(HUB_CONFIG_API, certificate) })
             .until(scheduler.action_result.certificate.in_use_at.present?)
  end

  def pollable_certificates
    Certificate.all_pollable
  end
end
