require 'rails_helper'

RSpec.describe NewMsaComponentEvent, type: :model do
  entity_id = 'http://test-entity-id'

  include_examples 'has data attributes', NewMsaComponentEvent, %i[name entity_id environment]
  include_examples 'is aggregated', NewMsaComponentEvent, name: 'New component', entity_id: entity_id, environment: ENVIRONMENT::STAGING
  include_examples 'is a creation event', NewMsaComponentEvent, name: 'New component', entity_id: entity_id, environment: ENVIRONMENT::STAGING

  context 'name' do
    it 'must be provided' do
      event = build(:new_msa_component_event, name: '', entity_id: entity_id, environment: ENVIRONMENT::STAGING)
      expect(event).to_not be_valid
      expect(event.errors[:name]).to eql ['can\'t be blank']
    end
  end

  context 'environment' do
    it 'must be provided' do
      event = build(:new_msa_component_event, name: 'New component', entity_id: entity_id, environment: '')
      expect(event).to_not be_valid
      expect(event.errors[:environment]).to eql ['can\'t be blank']
    end
  end
end
