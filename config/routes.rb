Rails.application.routes.draw do
  # JSON REST API (outside of the locale scope): versioned namespace api/v1
  namespace :api do
    namespace :v1 do
      get  "books", to: "books_api#index"   # next unrated book of a genre
      post "books", to: "books_api#create"  # save rating (1-100) and comment
    end
  end

  # Health check used by load balancers and uptime monitors
  get "up" => "rails/health#show", as: :rails_health_check

  # All browser-facing routes are wrapped in an optional locale segment:
  # /books, /ru/books and /en/books are all valid
  scope "(:locale)", locale: /en|ru/ do
    root "books#index"

    # Registration
    get  "signup", to: "users#new"
    post "signup", to: "users#create"

    # Manual session management
    get    "login",  to: "sessions#new"
    post   "login",  to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    # Evaluation workspace (page skeleton only, data comes from the API)
    get "books", to: "books#index"

    # Personal account and CSV export
    get "profile",        to: "profiles#show"
    get "profile/export", to: "profiles#export", as: :profile_export, defaults: { format: :csv }
  end

  # Custom handling of unknown routes instead of the default Routing Error page
  match "*path", to: "application#catch_404", via: :all
end
