Rails.application.routes.draw do
  namespace :api do
    namespace :v1, format: :json do
      resources :authentication, only: [:create]
      resources :users, only: [:create]
      resources  :games, only: [:index, :show]
      get 'users', to: 'users#approve'
    end
  end
end
