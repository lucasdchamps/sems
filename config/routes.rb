Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "stations/:id/status", to: "stations#status", as: "station_status"

  post "stations/:id/sessions", to: "stations#create_session", as: "create_session"

  delete "stations/:id/sessions/:session_id", to: "stations#delete_session", as: "delete_session"

  # Defines the root path route ("/")
  # root "posts#index"
end
