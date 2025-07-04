Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resources :games, only: [:show] do
    member do
      get :select_civilization
      post :join
      post :end_turn
    end
  end

  resources :user_games, only: [:update] do
    member do
      post :end_turn
    end

    resources :build_queues, only: [:create, :update, :destroy] do
      collection do
        delete :destroy_all
      end
    end

    resources :explore_queues, only: [:create, :destroy]
    resources :train_queues, only: [:create, :destroy] do
      collection do
        post :disband
      end
    end

    resources :trades, only: [] do
      collection do
        post :local_buy
        post :local_sell
        post :global_sell
        post :global_buy
        post :global_change_prices
        post :global_withdraw
        post :update_auto_trade
        get :global_market_data
      end
    end

    resources :attacks, only: [] do
      collection do
        post :army_attack
        post :catapult_attack
        post :thief_attack
      end

      member do
        get :cancel_attack
      end
    end
  end
end
