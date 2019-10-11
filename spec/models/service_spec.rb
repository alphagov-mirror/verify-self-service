require 'rails_helper'

RSpec.describe Service, type: :model do
  context 'adding components to a service' do
    let(:sp_component1) { create(:sp_component) }
    let(:sp_component2) { create(:sp_component) }
    let(:msa_component1) { create(:msa_component) }
    let(:msa_component2) { create(:msa_component) }
    let(:service) { create(:service, sp_components: [sp_component1]) }

    it 'should create a new service correctly' do
      expect(service).to be_valid
      expect(service).to be_persisted
    end

    it 'should be able to have mutiple sp and msa components' do
      service.sp_components << sp_component2
      service.msa_components << msa_component1
      service.msa_components << msa_component2
      expect(service).to be_valid
      expect(service).to be_persisted
    end
  end
end
