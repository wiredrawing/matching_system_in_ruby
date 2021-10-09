Rails.application.routes.draw do
  get "sessions/new"
  resources :logs
  resources :urls
  resources :declines
  resources :images
  resources :messages
  resources :timelines
  resources :footprints
  resources :likes
  resources :members
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  ##########################################
  # ログインページ
  ##########################################
  get "/signin", {
    :to => "sessions#new",
  }
  post "/signin", {
    :to => "sessions#create",
  }

  ##########################################
  # 新規登録時の仮登録
  ##########################################
  get "/register/:id/:token", {
    :to => "register#main_index",
    :as => "register_create",
  }
  post "/register/:id/:token", {
    :to => "register#main_create",
  }
  get "/signup/completed", {
    :to => "register#completed",
  }
  post "/signup", {
    :to => "register#create",
  }
  get "/signup", {
    :to => "register#index",
  }
end
