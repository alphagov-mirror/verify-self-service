module ApplicationHelper
   # @return the path to the login page
  def login_path
    case Rails.env
    when 'production'
      oauth_path('cognito-idp')
    when 'development'
      devauth_path
    when 'test'
      oauth_path('developer')
    end
  end

  def logout_url
    if session[:provider] == 'cognito-idp'
        query_params = {
                "client_id": Rails.application.secrets.cognito_client_id,
                "logout_uri": logout_callback_url
            }.to_query
        URI.join(
            Rails.application.secrets.cognito_user_pool_site,
            "logout?#{query_params}").to_s
    else
      logout_callback_url
    end
    
  end
end
