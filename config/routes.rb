Rails.application.routes.draw do

  ##########################################
  # api
  ##########################################
  namespace "api" do

    # 画像を取り扱うAPI
    scope "image" do
      scope "owner" do
        get "/:id", {
          :to => "images#show_owner",
          :as => "image_owner_show",
        }
      end
      scope "member" do
        get "/:id/:member_id", {
              :to => "images#show",
              :as => "image_show",
            }
      end
    end
  end

  get "sessions/new"
  resources :logs
  resources :urls
  resources :declines
  resources :images
  resources :messages
  resources :timelines
  resources :footprints
  # resources :likes
  resources :members
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  ##########################################
  # いいねを贈る
  ##########################################
  post "/like/send/:id", {
    :to => "likes#inform",
    :as => "inform_like",
  } # 異性にいいねを贈る
  post "/like/cancel/:id", {
    :to => "likes#cancel",
    :as => "cancel_like",
  }
  get "/likes/", { :to => "likes#index" } # 自身がもらったいいね一覧

  ##########################################
  # マイページ関連
  ##########################################
  get "/mypage", { :to => "mypage#index" }
  get "/mypage/edit", { :to => "mypage#edit" }
  patch "/mypage/edit", { :to => "mypage#update" }
  get ("/mypage/upload"), ({ :to => "mypage#upload" })
  post "/mypage/upload", { :to => "mypage#completed_uploading" }
  # 受信､送信済みのいいね一覧
  get ("/mypage/likes"), ({
        :to => "mypage#likes",
        :as => "mypage_likes",
      })
  # マッチング中ユーザー一覧
  get "/mypage/matching", {
    :to => "mypage#matching",
    :as => "mypage_matching",
  }

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
      :as => "create",
    }
    get "/", {
      :to => "register#index",
      :as => "index",
    }
    get "/:id/:token", {
      :to => "register#main_index",
      :as => "main_index",
    }
    post "/:id/:token", {
      :to => "register#main_create",
      :as => "main_create",
    }
    get "/completed", {
      :to => "register#completed",
      :as => "completed",
    }
    get "/pre-completed", {
      :to => "register#completed",
      :as => "pre-completed",
    }
  end
end
