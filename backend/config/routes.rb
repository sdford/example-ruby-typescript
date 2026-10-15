Rails.application.routes.draw do
  post "/login", to: "sessions#create"

  resources :projects, only: [:index, :show, :create, :update] do
    resources :share_links, only: [:create]
  end
  resources :share_links, only: [:index, :destroy]
  resources :memberships, only: [:index, :update]

  get "/shared/:token", to: "shared_projects#show"

  get "/up", to: proc { [200, {}, ["ok"]] }
end
