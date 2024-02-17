Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "rails/health#show"
  # config/routes.rb
resource :github_webhooks, only: :create, defaults: { formats: :json }

  post '/slack_events', to: 'slack_events#create'
  post '/test_team_join', to: 'slack_events#test_team_join'

  root "rails/health#show"
end
