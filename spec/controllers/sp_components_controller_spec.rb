require 'rails_helper'

RSpec.describe SpComponentsController, type: :controller do
  include AuthSupport

  let(:sp_component) { create(:sp_component) }

  describe "GET #index" do
    it "returns http success" do
      compmgr_stub_auth
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns http redirect for unauthorised user" do
      usermgr_stub_auth
      get :new
      expect(flash[:warn]).to match("You are not authorised to perform this action")
      expect(response).to have_http_status(:forbidden)
    end

    it "returns http success with component manager user" do
      compmgr_stub_auth
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      certmgr_stub_auth
      get :edit, params: { id: sp_component.id }
      expect(response).to have_http_status(:success)
    end
  end
end
