Rails.application.routes.draw do
  # Devise authentication
  devise_for :church_members, path: "auth", path_names: {
    sign_in: "login",
    sign_out: "logout",
    sign_up: "register"
  }, controllers: {
    registrations: "church_members/registrations",
    sessions: "church_members/sessions"
  }

  get "up" => "rails/health#show", as: :rails_health_check

  # PWA routes
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Church routes (public)
  get "churches/search", to: "churches#search", as: :search_churches
  resources :churches, only: [ :show, :new, :create ] do
    member do
      post :join
      get :thankyou
      get :pending_approval
    end
  end

  # Authenticated routes
  authenticate :church_member do
    resources :items do
      member do
        patch :toggle_availability
      end
      resources :borrow_requests, only: [ :new, :create ] do
        member do
          patch :owner_confirm
          patch :borrower_confirm
          patch :mark_returned
          patch :cancel
        end
      end
    end

    resources :services_listings, as: :services, path: "services"

    resources :needs do
      member do
        patch :fulfill
        patch :reopen
      end
    end

    resources :members, only: [ :index, :show ]

    resource :profile, only: [ :show, :edit, :update ]

    resource :church_admin, only: [ :show ], controller: "church_admin" do
      patch :update_settings
      post :approve_member
      post :reject_member
      post :toggle_admin
    end

    resource :notification_settings, only: [ :show, :update ]

    resources :push_subscriptions, only: [ :create ]

    # Dashboard / home for logged-in users
    get "dashboard", to: "dashboard#index", as: :dashboard
    get "my_listings", to: "dashboard#my_listings", as: :my_listings
    get "my_borrow_requests", to: "dashboard#my_borrow_requests", as: :my_borrow_requests
  end

  root "pages#home"

  # Superadmin routes
  namespace :superadmin, path: "superadmin" do
    root "dashboard#show"

    resources :churches, only: [ :index, :show ] do
      member do
        post :activate
        post :archive
        post :unarchive
        patch :update_settings
        post :promote_admin
        post :demote_admin
        post :approve_member
      end
    end

    resources :users, only: [ :index, :show, :destroy ] do
      member do
        post :suspend
        post :unsuspend
        post :impersonate
      end
    end

    post "users/stop_impersonating", to: "users#stop_impersonating", as: :stop_impersonating

    get "moderation", to: "moderation#index", as: :moderation_index
    delete "moderation/item/:id", to: "moderation#remove_item", as: :remove_item
    delete "moderation/service/:id", to: "moderation#remove_service", as: :remove_service
    delete "moderation/need/:id", to: "moderation#remove_need", as: :remove_need

    resource :telemetry, only: [ :show ], controller: "telemetry"
  end
end
