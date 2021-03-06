require 'rails_helper'

RSpec.describe 'New Team Page', type: :system do
  include CognitoSupport

  before(:each) do
    login_gds_user
  end
  let(:team_name) { 'test team' }
  let(:team_type) { 'rp' }

  context 'creation succeeds' do
    it 'when a valid name' do
      visit new_team_path
      fill_in 'team_name', with: team_name
      select team_type, from: "team_team_type"
      click_button t('team.new.create_team')

      expect(page).to have_content t('team.heading')
      expect(page).to have_content team_name
    end
  end

  context 'creation fails' do
    it 'when name is not specified' do
      visit new_team_path
      click_button t('team.new.create_team')

      expect(page).to have_content t('team.new.heading')
      expect(page).to have_content t('team.errors.blank_name')
    end

    it 'when team_type is not specified' do
      visit new_team_path
      fill_in 'team_name', with: team_name
      click_button t('team.new.create_team')

      expect(page).to have_content t('team.new.heading')
      expect(page).to have_content t('team.errors.team_type_invalid')
    end

    it 'when name is not unique' do
      visit new_team_path
      fill_in 'team_name', with: team_name
      select team_type, from: "team_team_type"
      click_button t('team.new.create_team')

      visit new_team_path
      fill_in 'team_name', with: team_name
      select team_type, from: "team_team_type"
      click_button t('team.new.create_team')

      expect(page).to have_content t('team.new.heading')
      expect(page).to have_content t('team.errors.name_not_unique')
    end
  end

  context 'failed to create cognito group' do
    it 'shows correct error message with invalid group name' do
      stub_cognito_response(
        method: :create_group,
        payload: Aws::CognitoIdentityProvider::Errors::InvalidParameterException.new("error", "error")
      )
      visit new_team_path
      fill_in 'team_name', with: team_name
      select team_type, from: "team_team_type"
      click_button t('team.new.create_team')

      expect(page).to have_content t('team.new.heading')
      expect(page).to have_content t('team.errors.failed')
    end

    it 'shows general failed to create message on error' do
      stub_cognito_response(
        method: :create_group,
        payload: Aws::CognitoIdentityProvider::Errors::ServiceError.new("error", "error", {})
      )
      visit new_team_path
      fill_in 'team_name', with: team_name
      select team_type, from: "team_team_type"
      click_button t('team.new.create_team')

      expect(page).to have_content t('team.new.heading')
      expect(page).to have_content t('team.errors.failed')
    end
  end
end
