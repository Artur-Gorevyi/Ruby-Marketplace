Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"

  # Authentication routes
  get "register", to: "registrations#new", as: :register
  post "register", to: "registrations#create"
  
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # Products routes (for buyers/visitors)
  resources :products, only: [:index, :show]
  
  # Search route (same as products#index but with search param)
  get "search", to: "products#index", as: :search

  # Seller routes
  namespace :seller do
    root "dashboard#index"
    resources :products
  end
end