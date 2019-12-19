require 'webmock'
require 'api/hub_config_api'

class StubHubConfigApi < HubConfigApi
  include WebMock::API
  WebMock.enable!
  def healthcheck(environment)
    stub_request(:get, URI.join(hub_environment(environment, :hub_config_host), HEALTHCHECK_ENDPOINT).to_s)
      .to_return(status: 200)
    super
  end

  def encryption_certificate(environment, entity_id)
    stub_request(:get, URI.join(hub_environment(environment, :hub_config_host), CERTIFICATES_ROUTE, CERTIFICATE_ENCRYPTION_ENDPOINT % { entity_id: CGI.escape(entity_id) }).to_s)
    .to_return(body: {
      issuerId: entity_id,
      certificate: 'encryption_certificate',
      keyUse: 'Encryption',
      federationEntityType: 'RP',
    }.to_json)
    super
  end

  def signing_certificates(environment, entity_id)
    stub_request(:get, URI.join(hub_environment(environment, :hub_config_host), CERTIFICATES_ROUTE, CERTIFICATES_SIGNING_ENDPOINT % { entity_id: CGI.escape(entity_id) }).to_s)
    .to_return(body: [{
      issuerId: entity_id,
      certificate: 'signing_certificate_one',
      keyUse: 'Signing',
      federationEntityType: 'RP',
    }].to_json)
    super
  end
end
