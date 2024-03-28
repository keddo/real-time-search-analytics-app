Rails.application.routes.draw do
  resources :posts
   get '/api/articles', to: 'article#index'
   get '/api/articles/search/:query', to: 'search#search'
   get '/api/search/analytics', to: 'search#analytics'
   # Define route for search_trends endpoint
   get '/api/search/search_trends', to: 'search#search_trends'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "posts#index"
end
