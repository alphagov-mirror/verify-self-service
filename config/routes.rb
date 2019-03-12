Rails.application.routes.draw do
  get 'auth/callback'
  get 'auth/failure'
  get 'home/index', to: 'home#index'
  get '/upload', to: 'certificates#upload'
  post '/upload', to: 'certificates#create'

  get '/certificates', to: 'certificates#index'
  root 'certificates#index'
  get '/events', to: 'events#index'
  get '/events/:page', to: 'events#page'

  get '/devauth' => 'dev_auth#show'
  # Dashboard
  get 'dashboard' => 'dashboard#show'
  get   '/login', :to => 'sessions#new', :as => :login
  match '/auth/:provider/callback', :to => 'auth#callback', :via => [:get, :post]
  match '/auth/failure', :to => 'auth#failure', :via => [:get, :post]
  get '/logout/', :to => 'auth#logout'
  get '/logout/callback', :to => 'auth#destroy'
end
