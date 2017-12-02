Rails.application.routes.draw do
  namespace :api do
    namespace :v1, format: :json do
      resources :authentication, only: [:create]
      resources :games, only: [:create, :index, :show, :destroy]
      post :ai_game, to: 'games#create_ai_game'
      resources :users, only: [:create]
      resources :game_over, only: [:update]
      resources :accept_challenge, only: [:show]
      resources :moves, only: [:create]
      post :ai_move, to: 'moves#create_ai_move'
      patch :analytics, to: 'analytics#analysis'
      get :users, to: 'users#approve'
    end
  end
end
