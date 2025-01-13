Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Admin
  get "/admin", to: "admin/home#index"
  namespace :admin do
    resources :enterprises, except: %i[index destroy]
  end

  # Campaigns
  namespace :campaigns do
    get "marketer/show"
    # Invitations
    resources :invitations, param: :token, except: %i[index destroy]
    # Sessions
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    # Registration
    get "/account", to: "marketers#edit"
    patch "/account", to: "marketers#update"
    # Password
    resources :passwords, param: :token, except: %i[index show]

    # Enterprises
    resources :merchants, except: :destroy do
    end
    put "merchants/:id/location", to: "merchants#location", as: "merchant_location"

    get "/account", to: "marketers#edit"
    patch "/account", to: "marketers#update"
  end

  # Registration
  get "/account", to: "admins#edit"
  patch "/account", to: "admins#update"
  resources :user_invitations, only: %i[new create edit update]

  # Session
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # Enterprises
  get "/settings", to: "enterprises#edit", as: :enterprise_setting
  delete "remove_user/:user_id", to: "enterprises#remove_user", as: :remove_enterprise_user

  # Branches
  resources :branches, except: %i[index destroy]

  # Password
  resources :passwords, param: :token, except: %i[index show]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :deliveries do
    collection do
      get :search_customer
      get :search_branch
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "enterprises#index"
end
