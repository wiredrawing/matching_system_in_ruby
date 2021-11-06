Rails.application.routes.draw do

  # TOPページ
  get "/", {
    :to => "top#index",
    :as => "top",
  }

  # api
  namespace "api" do

    # 画像を取り扱うAPI
    scope "image" do

      # ログインユーザーがアップ済みの画像一覧を取得する
      get "/list", {
        :to => "images#list",
        :as => "images_owner_has",
      }
      # 指定した異性ユーザーの全画像を取得する
      get "/list/:member_id", {
        :to => "images#member",
        :as => "images_selected_member_has",
      }
      # 画像表示用 URL(※所有者のみ閲覧可能)
      get "/:id/:member_id/:token_for_api", {
        :to => "images#owner_image_url",
        :as => "private_image",
      }
      # 画像表示用 URL(※第三者閲覧用)
      get "/:id/:token", {
        :to => "images#image_url",
        :as => "public_image",
      }
      # To upload any images.
      post "/update/:id", {
        :to => "images#update",
        :as => "image_update",
      }
      post "/delete/:id", {
        :to => "images#delete",
        :as => "image_delete",
      }
      post "/", {
        :to => "images#upload",
        :as => "image_upload",
      }
    end

    # メッセージ送信用
    scope "timeline" do
      get "/messages/:from_member_id/:to_member_id", {
        :to => "timelines#message_list",
        :as => "timeline_messages",
      }
      post "/", {
        :to => "timelines#create_message",
        :as => "timeline_create_message",
      }
    end

    # API用ユーティリティー情報
    scope "utilities" do
      get "/get", {
        :to => "utilities#get",
        :as => "utilities_list",
      }
    end
  end

  get "sessions/new"
  resources :logs
  resources :urls
  resources :declines
  # resources :images
  # resources :messages
  # resources :timelines
  resources :footprints
  # resources :likes
  resources :members
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  post "/images/active/:id", {
    :to => "images#active",
    :as => "active_image",
  }

  post "/images/deactive/:id", {
    :to => "images#deactive",
    :as => "deactive_image",
  }

  ##########################################
  # メッセージ
  ##########################################
  get "/messages/", {
    :to => "messages#index",
    :as => "messages",
  }
  get "/messages/:id", {
    :to => "messages#talk",
    :as => "message_talk",
  }
  post "/messages/create", {
    :to => "messages#create",
    :as => "message_create",
  }

  ##########################################
  # いいねを贈る
  ##########################################
  # 異性にいいねを贈る
  post "/like/send/:id", {
    :to => "likes#inform",
    :as => "inform_like",
  }
  # 贈ったいいねをキャンセル
  post "/like/cancel/:id", {
    :to => "likes#cancel",
    :as => "cancel_like",
  }

  ##########################################
  # マイページ関連
  ##########################################
  get "/mypage", { :to => "mypage#index" }
  get "/mypage/edit", { :to => "mypage#edit" }
  patch "/mypage/edit", { :to => "mypage#update" }
  # 画像のぼかし具合を設定
  post "/mypage/upload/:id", {
    :to => "mypage#update_image",
    :as => "mypage_update_image",
  }
  get "/mypage/upload", {
    :to => "mypage#upload",
  }
  post "/mypage/upload", { :to => "mypage#completed_uploading" }
  delete "/mypage/delete_image", {
    :to => "mypage#delete_image",
  }

  # 贈ったいいね
  get "/mypage/informing_likes", {
        :to => "mypage#informing_likes",
        :as => "mypage_informing_likes",
      }
  # もらったいいね
  get "/mypage/getting_likes", {
        :to => "mypage#getting_likes",
        :as => "mypage_getting_likes",
      }
  # マッチング中ユーザー一覧
  get "/mypage/matching", {
    :to => "mypage#matching",
    :as => "mypage_matching",
  }
  # ブロック中ユーザー一覧
  get "/mypage/blocking", {
    :to => "mypage#blocking",
    :as => "mypage_blocking",
  }
  # 足跡一覧
  get "/mypage/footprints", {
    :to => "mypage#footprints",
    :as => "mypage_footprints",
  }
  # ログ一覧
  get "/mypage/logs", {
    :to => "mypage#logs",
    :as => "mypage_logs",
  }
  get "/mypage/logout", {
    :to => "mypage#logout",
    :as => "logout",
  }
  # ログイン中ユーザーが自身のプロフィール画面を閲覧する
  get "/mypage/profile", :to => "mypage#prfile", :as => "mypage_profile"

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
