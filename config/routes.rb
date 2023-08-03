Rails.application.routes.draw do
  root 'home#index'
  
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'

  delete 'logout', to: 'sessions#destroy'

  resource :user, only: %i[show]

  get 'deposit', to: 'accounts#new'
  post 'deposit', to: 'accounts#deposit'

  resource :wallet, only: %i[show new create]

  get 'wallet/deposit', to: 'wallets#deposit_new'
  post 'wallet/deposit', to: 'wallets#deposit'

  get 'wallet/withdraw', to: 'wallets#withdraw_new'
  post 'wallet/withdraw', to: 'wallets#withdraw'

  post 'authorization', to: 'authorizations#index'
end
