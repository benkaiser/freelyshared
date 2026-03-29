Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Church routes
  get "churches/search", to: "churches#search", as: :search_churches
  resources :churches, only: [:show, :new, :create] do
    member do
      post :join
      get :thankyou
    end
  end

  root "pages#home"
end
