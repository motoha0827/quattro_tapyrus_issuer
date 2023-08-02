Rails.application.routes.draw do
  root 'home#index'
  
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'

  delete 'logout', to: 'sessions#destroy'

  resource :user, only: %i[show]

  resource :account, only: %i[show] do
    scope module: :accounts do
      resource :deposit, only: %i[new create]
      resource :withdrawal, only: %i[new create]
      resource :transfer, only: %i[new create]
    end
  end
end
