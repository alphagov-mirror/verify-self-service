require 'yaml'
require 'rails_helper'

RSpec.describe PublishServicesMetadataEvent, type: :model do
  include StorageSupport

  let(:published_at) { Time.now }
  let(:event_id) { 0 }
  let(:component) { MsaComponent.create(name: 'lala', entity_id: 'https//test-entity') }
  let(:event) { PublishServicesMetadataEvent.create(event_id: event_id, environment: 'test') }

  context '#create' do
    it 'creates a valid event which contains hard-coded data' do
      expect(event.data).to include(
        'event_id',
        'services_metadata'
      )
      expect(event.data['services_metadata']).to include('published_at')
    end

    it 'when event_id is blank services_metadata json is empty' do
      invalid_event = PublishServicesMetadataEvent.create
      event_error = invalid_event.errors.messages[:event_id]
      expect(invalid_event).to_not be_valid
      expect(invalid_event.data).to be_empty
      expect(event_error).to include("can't be blank")
    end
  end

  context 'upload' do
    it 'when environment is set to integration on component' do
      expect(
        SelfService.service(:storage_client)
      ).to receive(:put_object).with(hash_including(bucket: "integration-bucket"))

      PublishServicesMetadataEvent.create(event_id: 0, environment: 'integration')
    end

    it 'when environment is set to production on component' do
      expect(
        SelfService.service(:storage_client)
      ).to receive(:put_object).with(hash_including(bucket: "production-bucket"))

      PublishServicesMetadataEvent.create(event_id: 0, environment: 'production')
    end

    it 'does not persist event if publishing to s3 fails' do
      stub_storage_client_service_error

      event = PublishServicesMetadataEvent.create(event_id: event_id, environment: 'staging')
      expect(event).not_to be_persisted
    end
  end

  context 'initiate hub polling' do
    let(:service) { create(:service) }
    let(:msa_encryption_certificate) { create(:msa_encryption_certificate, component: create(:msa_component)) }
    let(:sp_encryption_certificate) { create(:sp_encryption_certificate, component: create(:sp_component)) }
    let(:vsp_encryption_certificate) { create(:vsp_encryption_certificate, component: create(:sp_component, vsp: true)) }
    let(:msa_signing_certificate) { create(:msa_signing_certificate, component: create(:msa_component)) }
    let(:sp_signing_certificate) { create(:sp_signing_certificate, component: create(:sp_component)) }
    let(:vsp_signing_certificate) { create(:vsp_signing_certificate, component: create(:sp_component, vsp: true)) }

    before(:each) do
      SpComponent.destroy_all
      MsaComponent.destroy_all
      create(:replace_encryption_certificate_event,
        component: sp_encryption_certificate.component,
        encryption_certificate_id: sp_encryption_certificate.id
      )
      create(:assign_sp_component_to_service_event, service: service, sp_component_id: sp_encryption_certificate.component.id)
      create(:replace_encryption_certificate_event,
        component: msa_encryption_certificate.component,
        encryption_certificate_id: msa_encryption_certificate.id
      )
      create(:replace_encryption_certificate_event,
        component: vsp_encryption_certificate.component,
        encryption_certificate_id: vsp_encryption_certificate.id
      )
    end
    it "assigns some association after commit" do

    end

    it 'when there are certificates not in_use by components with services' do
      expect(Certificate.all_pollable('staging')).to include(sp_encryption_certificate)
    end
    it 'does not when no certificates are in_use by components with services' do
      expect(Certificate.all_pollable('staging')).not_to include(msa_encryption_certificate, msa_encryption_certificate)
    end
  end
end
