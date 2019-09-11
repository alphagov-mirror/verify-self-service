require 'rails_helper'

RSpec.describe 'New SP Component Page', type: :system do
  before(:each) do
    login_gds_user
    create_teams
  end

  let(:entity_id) { 'http://test-entity-id' }
  let(:team) { create(:new_team_event).team }
  let(:create_teams) { team }

  context 'creation is successful' do
    it 'when required input is specified' do
      component_name = 'test component'
      visit new_sp_component_path
      choose 'component_component_type_vspcomponent', allow_label_click: true
      choose 'component_environment_staging'
      fill_in 'component_name', with: component_name
      select team.name, from: "component_team_id"
      click_button 'Create SP component'

      expect(current_path).to eql admin_path
    end
  end

  context 'creation fails without name' do
    it 'when name is not specified' do
      component_name = ''
      visit new_sp_component_path
      choose 'component_component_type_vspcomponent', allow_label_click: true
      choose 'component_environment_staging'
      fill_in 'component_name', with: component_name
      select team.name, from: "component_team_id"
      click_button 'Create SP component'

      expect(page).to have_content 'Name can\'t be blank'
    end
  end

  context 'creation fails without team id' do
    it 'when team id is not specified for msa component' do
      component_name = 'test component'
      visit new_sp_component_path
      choose 'component_component_type_vspcomponent', allow_label_click: true
      choose 'component_environment_staging'
      fill_in 'component_name', with: component_name
      click_button 'Create SP component'

      expect(page).to have_content 'Team can\'t be blank'
    end
  end
end
