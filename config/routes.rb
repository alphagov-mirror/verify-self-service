Rails.application.routes.draw do
  resources :teams, path: 'admin/teams', only: %i[index new create]

  devise_for :users, controllers: { sessions: 'sessions' }

  root 'components#index'

  get '/healthcheck', to: 'healthcheck#index'

  get '/admin', to: 'components#index'

  resources :sp_components, path: 'admin/sp-components' do
    resources :services
    resources :certificates do
      member do
        patch 'enable'
        patch 'disable'
        patch 'replace'
      end
    end
  end

  resources :msa_components, path: 'admin/msa-components' do
    resources :services
    resources :certificates do
      member do
        patch 'enable'
        patch 'disable'
        patch 'replace'
      end
    end
  end

  get '/admin/events', to: 'events#index'
  get '/admin/events/:page', to: 'events#page'

  get '/users', to: 'users#index', as: :users
  get '/users/invite', to: 'users#invite', as: :invite_user
  post '/users/invite', to: 'users#new', as: :invite_new_user

  get '/mfa-enrolment', to: 'mfa#index', as: :mfa_enrolment
  post '/mfa-enrolment', to: 'mfa#enrol', as: :enrol_to_mfa

  if %w(test development).include? Rails.env
    # Dashboard
    get 'profile', to: 'profile#show'
  end
end
