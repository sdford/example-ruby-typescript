Rails.application.routes.draw do
  post "/login", to: "sessions#create"

  resources :projects, only: [:index, :show, :create, :update]

  get "/up", to: proc { [200, {}, ["ok"]] }
end
