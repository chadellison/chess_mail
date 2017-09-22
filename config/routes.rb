Rails.application.routes.draw do
  namespace :api do
    namespace :v1, format: :json do
      resources :authentication, only: [:create]
      resources :users, only: [:create]
      resources :games, only: [:create, :index, :show, :destroy]
      resources :moves, only: [:create]
      resources :accept_challenge, only: [:show]
      patch 'games/end_game/:id', to: 'games#end_game'
      get 'users', to: 'users#approve'
    end
  end
end
