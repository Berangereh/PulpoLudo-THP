Rails.application.routes.draw do
  
  get 'static_pages/landing'
  get 'static_pages/team'
  get 'static_pages/contact'


  devise_for :users

  devise_scope :user do
    authenticated :user do
      root 'game_sheets#index'
    end
    unauthenticated do
      root 'static_pages#landing'
    end
  end

  resources :users do
    resources :avatars, only: [:create]
    resources :addresses, except: [:show]
    resources :orders, only: [:index, :show, :create, :update] do
      resources :shippings, only: [:show, :update]
    end
    resources :subscriptions, except: [:show]
  end

  resources :game_sheets, only: [:index, :show] do
    resources :game_pictures, only: [:create]
  end

  namespace :admin do
    root to: 'games#index'
    resources :games, except: [:show, :destroy]
    resources :game_sheets, except: [:show, :destroy]
    resources :users, except: [:show, :new, :create]
  end

  resources :carts, only: [:show, :update]

  resources :games, only: [:update]

  namespace :stripe do
    resources :checkouts
    get 'checkout/success', to: 'checkouts#success', as: 'checkouts_success'
    get 'checkout/cancel', to: 'checkouts#cancel', as: 'checkouts_cancel'
    post 'checkout/webhook', to: 'checkouts#webhook'
    resources :checkoutorders
    get 'checkoutorder/success', to: 'checkoutorders#success', as: 'checkoutorders_success'
    get 'checkoutorder/cancel', to: 'checkoutorders#cancel', as: 'checkoutorders_cancel'
  end
  
end
