require 'yaml'
require 'rails_helper'

RSpec.describe UserSignInEvent, type: :model do
  let(:user_id) { SecureRandom.uuid }
  let(:event) { UserSignInEvent.create(user_id: user_id) }
  let(:event_with_nil_user_id) {
    UserInfo.current_user = nil
    UserSignInEvent.create(user_id: nil)
  }

  context '#create' do
    it 'a valid event which contains a user id' do

      expect(event.user_id).to eq(user_id)
    end

    it 'an event which contains no user id' do
      Thread.current[:user].user_id = nil
      nil_event = UserSignInEvent.create(user_id: nil)
      expect(nil_event.user_id).to eq(nil)
    end
  end
end
