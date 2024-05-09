Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    resources :games, only: [:show, :create, :update]
  end

  resources :games, only: [:index, :show]

  root 'games#index'
end
