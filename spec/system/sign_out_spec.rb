require 'rails_helper'
RSpec.describe 'Sign out', type: :system do
  scenario 'user can sign out' do
    SelfService.service(:cognito_client).stub_responses(:initiate_auth, { challenge_name: nil, authentication_result: {access_token: "valid-token" }})

    user = FactoryBot.create(:user)
    sign_in(user.email, user.password)
    expect(page).to have_content 'Signed in successfully.'
    click_link 'Sign out'

    expect(current_path).to eql new_user_session_path
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
