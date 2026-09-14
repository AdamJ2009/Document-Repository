Rails.application.routes.draw do
  resources :passwords
  root "documents#index"

  # Authentication session route
  resource :session, only: [:new, :create, :destroy]

  resources :folders, only: [:index, :show, :create, :update] do
    member do
      patch :archive
      patch :restore
    end
    collection do
      get :archived
    end
  end

  resources :archives, only: [:index, :show] do
    member do
      patch :restore
    end
  end

  resources :documents do
    collection do
      get :archived
    end
    member do
      patch :restore
    end
  end
end