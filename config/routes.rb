Rails.application.routes.draw do

  root 'components#index'
  resources :components do
    resources :certificates do
      member do
        patch 'enable'
        patch 'disable'
        patch 'replace'
      end
    end
  end

  get '/events', to: 'events#index'
  get '/events/:page', to: 'events#page'

  match '/auth/:provider/callback', :to => 'auth#callback', :via => [:get, :post]
  match '/auth/failure', :to => 'auth#failure', :via => [:get, :post]
  get '/logout/', :to => 'auth#logout', :as => 'logout'
  get '/logout/callback', :to => 'auth#destroy', :as => 'logout_callback'

  if %w(test development).include? Rails.env
    get '/devauth' => 'dev_auth#show'
    # Dashboard
    get 'dashboard' =>'dashboard#show'
  end
end
