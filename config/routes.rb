Rails.application.routes.draw do
  namespace :api do
    namespace :v1, format: :json do
      resources :authentication, only: [:create]
      resources :users, only: [:create]
      resources :games, only: [:create, :index, :show, :destroy]
      resources :moves, only: [:create]
      resources :game_over, only: [:update]
      resources :accept_challenge, only: [:show]
      patch 'analytics', to: 'analytics#analysis'
      get 'users', to: 'users#approve'
    end
  end
end
