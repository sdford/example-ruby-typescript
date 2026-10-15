Rails.application.routes.draw do
  post "/login", to: "sessions#create"
  post "/login/mfa", to: "sessions#verify_mfa"

  post "/mfa/setup", to: "mfa#setup"
  post "/mfa/enable", to: "mfa#enable"
  get "/mfa/backup_codes", to: "mfa#backup_codes"
  get "/mfa/status", to: "mfa#status"
  delete "/mfa", to: "mfa#destroy"
  post "/users/:user_id/mfa/reset", to: "mfa#reset"

  resources :projects, only: [:index, :show, :create, :update]

  get "/up", to: proc { [200, {}, ["ok"]] }
end
