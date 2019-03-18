    def stub_auth
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({'extra' => { 'raw_info' =>{
            'uid' => '12032019',
            'info' => {
            'name' => 'Test User'
            }
        }}, 'provider' => 'test-idp'})
        OmniAuth.config.add_mock(:developer, {:provider => 'developer'})
    
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:cognito_idp]
    end

    def get_auth_hash
        request.env['omniauth.auth'] = auth_hash = OmniAuth::AuthHash.new({'extra' => { 'raw_info' =>{
            'uid' => '12032019',
            'info' => {
            'name' => 'Test User'
            }
        }}, 'provider' => 'test-idp'})
    end

    def populate_session
        session[:userinfo] = "Test User"
        session[:provider] = "test-idp"
    end