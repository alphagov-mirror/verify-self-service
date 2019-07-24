require 'rails_helper'

RSpec.describe Devise::SessionsController, type: :controller do

    it "test auth path (i.e. should render MFA partial)" do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        session[:challenge_name] = "MFA"

        get :new
        expect(subject).to render_template(:partial => '_mfa_form')
    end

    it "test strategy (to test different logical flows in strategy)" do

        #@request = double(:request)
        strategy = Devise::Strategies::RemoteAuthenticatable.new(nil)
        allow(request).to receive(:headers).and_return({user:"name"})
        allow(strategy).to receive(:params).at_least(:once).and_return({user:"name"})
        #@strategy.should_receive(:request).and_return(@request)

        request.env["devise.mapping"] = Devise.mappings[:user]
        @mapping = double(:mapping)
        allow(@mapping).to receive(:to).and_return(Devise.mappings[:user])
        
        strategy.authenticate!.should eq :success
        #expect(response).to have_http_status(:success)
    end
end