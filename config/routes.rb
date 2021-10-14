Rails.application.routes.draw do

  ##########################################
  # api
  ##########################################
  namespace "api" do
    resources :images
  end

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
  # マイページ関連
  ##########################################
  get "/mypage", { :to => "mypage#index" }
  get "/mypage/edit", { :to => "mypage#edit" }
  patch "/mypage/edit", { :to => "mypage#update" }
  get ("/mypage/upload"), ({ :to => "mypage#upload" })
  post "/mypage/upload", { :to => "mypage#completed_uploading" }
  ##########################################
  # ログインページ
  ##########################################
  scope "login", :as => :login do
    get "/", {
      :to => "sessions#new",
    }
    post "/", {
      :to => "sessions#create",
    }
  end

  ##########################################
  # 新規登録時の仮登録
  ##########################################
  scope("register", :as => :register) do
    post "/", {
      :to => "register#create",
    }
    get "/", {
      :to => "register#index",
    }
    get "/:id/:token", {
      :to => "register#main_index",
    # :as => "register_create",
    }
    post "/:id/:token", {
      :to => "register#main_create",
    }
    get "/completed", {
      :to => "register#completed",
    }
    get "/pre-completed", {
      :to => "register#completed",
    }
  end
end
