require 'rails_helper'

RSpec.describe 'Sign in', type: :system do
  scenario 'user cannot sign in if not registered' do
    SelfService.service(:cognito_client).stub_responses(:initiate_auth, Aws::CognitoIdentityProvider::Errors::UserNotFoundException.new(nil, "Stub Response"))
    
    sign_in('unregistered@example.com', 'testtest')

    expect(current_path).to eql new_user_session_path
    expect(page).to have_content 'Invalid Username or Password.'
  end

  scenario 'user can sign in with valid credentials' do
    SelfService.service(:cognito_client).stub_responses(:initiate_auth, { authentication_result: {access_token: "valid-token" }})

    user = FactoryBot.create(:user)
    sign_in(user.email, user.password)

    expect(current_path).to eql root_path
    expect(page).to have_content 'Signed in successfully.'
  end

  scenario 'user can sign in with valid 2FA credentials' do
    SelfService.service(:cognito_client).stub_responses(:initiate_auth, { challenge_name: "SOFTWARE_TOKEN_MFA", session: SecureRandom.uuid, challenge_parameters: { 'FRIENDLY_DEVICE_NAME' => 'Authy', 'USER_ID_FOR_SRP' => '0000-0000' }})
    SelfService.service(:cognito_client).stub_responses(:respond_to_auth_challenge, { authentication_result: {access_token: 'valid-token' }})

    user = FactoryBot.create(:user)
    sign_in(user.email, user.password)
    expect(current_path).to eql new_user_session_path
    expect(page).to have_content 'Log in - One Time Password Request'

    fill_in "user[totp_code]", with: "000000"
    click_button("commit")
    expect(current_path).to eql root_path
    expect(page).to have_content 'Signed in successfully.'
    # Ensure session is cleaned up from flow
    expect(page.get_rack_session.has_key?(:username)).to eql false
    expect(page.get_rack_session.has_key?(:cognito_session_id)).to eql false
    expect(page.get_rack_session.has_key?(:challenge_name)).to eql false
    expect(page.get_rack_session.has_key?(:challenge_parameters)).to eql false
  end

  scenario 'user cant sign in with wrong 2FA credentials' do
    SelfService.service(:cognito_client).stub_responses(:initiate_auth, { challenge_name: "SOFTWARE_TOKEN_MFA", session: SecureRandom.uuid, challenge_parameters: { "FRIENDLY_DEVICE_NAME" => 'Authy', 'USER_ID_FOR_SRP' => '0000-0000' }})
    SelfService.service(:cognito_client).stub_responses(:respond_to_auth_challenge, Aws::CognitoIdentityProvider::Errors::CodeMismatchException.new(nil, "Stub Response"))

    user = FactoryBot.create(:user)
    sign_in(user.email, user.password)
    expect(current_path).to eql new_user_session_path
    expect(page).to have_content 'Log in - One Time Password Request'

    fill_in "user[totp_code]", with: "999999"
    click_button("commit")
    expect(current_path).to eql new_user_session_path
    expect(page).to have_content 'Invalid Username or Password.'
  end

  scenario 'user cannot sign in with wrong email' do
    SelfService.service(:cognito_client).stub_responses(:initiate_auth, Aws::CognitoIdentityProvider::Errors::UserNotFoundException.new(nil, "Stub Response"))

    user = FactoryBot.create(:user)
    sign_in('invalid@email.com', user.password)

    expect(current_path).to eql new_user_session_path
    expect(page).to have_content 'Invalid Username or Password.'
  end

  scenario 'user cannot sign in with wrong password' do
    user = FactoryBot.create(:user)
    sign_in(user.email, 'invalidpassword')

    expect(current_path).to eql new_user_session_path
    expect(page).to have_content 'Invalid Username or Password.'
  end

  scenario 'user cannot access pages if not signed in' do
    visit new_msa_component_path

    expect(current_path).to eql new_user_session_path
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
