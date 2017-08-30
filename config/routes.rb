Rails.application.routes.draw do
  namespace :api do
    namespace :v1, format: :json do
      resources :authentication, only: [:create]
      resources :users, only: [:create]

      get 'users/:user_id/games', to: 'games#index'

      get 'users', to: 'users#approve'
    end
  end
end
