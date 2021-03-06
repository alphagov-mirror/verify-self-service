require 'rails_helper'

RSpec.describe NewMsaComponentEvent, type: :model do
  include_examples 'components have data attributes', :new_msa_component_event, {
    name: 'Call me Ishmael',
    environment: 'staging',
    entity_id: SecureRandom.alphanumeric
  }
  include_examples 'components are aggregated', :new_msa_component_event
  include_examples 'component creation event', :new_msa_component_event

  context 'name' do
    it 'must be provided' do
      event = build(:new_msa_component_event, name: '')
      expect(event).to_not be_valid
      expect(event.errors[:name]).to eql [t('events.errors.missing_name')]
    end
  end

  context 'team_id' do
    it 'must be provided' do
      event = build(:new_msa_component_event, team_id: '', environment: 'staging')
      expect(event).to_not be_valid
      expect(event.errors[:team_id]).to eql [t('components.errors.invalid_team')]
    end
  end

  context 'environment' do
    it 'must be provided' do
      event = build(:new_msa_component_event, environment: '')
      expect(event).to_not be_valid
      expect(event.errors[:environment]).to eql [t('components.errors.invalid_environment')]
    end
  end

  context 'entity_id' do
    it 'must be provided' do
      event = build(:new_msa_component_event, entity_id: '')
      expect(event).to_not be_valid
      expect(event.errors[:entity_id]).to eql [t('components.errors.missing_entity_id')]
    end

    it 'is valid when there is only leading and trailing whitespaces' do
      event = build(:new_msa_component_event, entity_id: ' https://test-entity-id ')
      expect(event).to be_valid
      expect(event.errors[:entity_id]).to eql []
      expect(event.entity_id).to eql "https://test-entity-id"
    end

     it 'must not contain spaces between words' do
      event = build(:new_msa_component_event, entity_id: 'https://test entity id')
      expect(event).to_not be_valid
      expect(event.errors[:entity_id]).to eql [t('components.errors.invalid_entity_id_format')]
    end
  end
end