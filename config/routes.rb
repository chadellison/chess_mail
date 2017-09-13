Rails.application.routes.draw do
  namespace :api do
    namespace :v1, format: :json do
      resources :authentication, only: [:create]
      resources :users, only: [:create]
      resources  :games, only: [:create, :index, :show, :update, :destroy]
      get 'games/accept/:game_id', to: 'games#accept'
      get 'users', to: 'users#approve'
    end
  end
end
