Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  root "documents#index"
  resources :documents
  resources :archives
end