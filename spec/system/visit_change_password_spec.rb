require 'rails_helper'

RSpec.describe 'ChangePassword', type: :system do
  include AuthSupport, CognitoSupport, NotifySupport
  before(:each) do
    login_gds_user
  end

  it 'shows form' do
    visit profile_change_password_path
    expect(page).to have_content t('password.current_password_lbl')
  end

  it 'shows errors when an empty form is submitted' do
    visit profile_change_password_path
    click_button 'Change password'
    forms = page.find("#new_change_password_form")
    expect(forms).to have_content "Old password can't be blank"
    expect(forms).to have_content "Password can't be blank"
    expect(forms).to have_content "Password confirmation can't be blank"
  end

  it 'submits the form correctly without error' do 
    stub_cognito_response(method: :change_password, payload: {})
    stub_notify_response
    expected_body = {
      email_address: "test.test@digital.cabinet-office.gov.uk",
      template_id: "16557e1a-767f-42d9-a8d6-7f35ca57f0dd",
      personalisation: {
        first_name: "John",
      }
    }
    visit profile_change_password_path
    fill_in 'change_password_form[old_password]', with: '12345678'
    fill_in 'change_password_form[password]', with: "87654321"
    fill_in 'change_password_form[password_confirmation]', with: "87654321"
    click_button 'Change password'
    expect(current_path).to eql profile_path
    expect(page).to have_content t('password.password_changed')
    expect(stub_notify_request(expected_body)).to have_been_made.once
  end
end
