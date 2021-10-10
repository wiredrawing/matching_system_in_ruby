class Member < ApplicationRecord

  # emailバリデーション
  validates(:email, {
    :presence => true,
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "メールアドレスはは1文字以上512文字以内で入力して下さい",
    },
  })

  # display_name(本名とは違うニックネーム表示用)
  validates :display_name, {
    :presence => true,
    :length => {
      :minimum => 5,
      :maximum => 128,
      :message => "ニックネームは5文字以上128文字以内で入力して下さい",
    },
  }

  # 性別
  validates(:gender, {
    :presence => true,
    :length => {
      :minimum => 0,
    },
  })

  validates :given_name, {
    :presence => true,
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "名前は1文字以上512文字以内で入力して下さい",
    },
  }

  validates :family_name, {
    :presence => true,
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "名字は1文字以上512文字以内で入力して下さい",
    },
  }

  # パスワード
  validates(:password, {
    :presence => true,
    :length => {
      :minimum => 10,
      :maximun => 64,
    },
  })

  # パスワード確認用
  validates (:password_confirmation), ({
    :presence => true,
    :length => {
      :minimum => 10,
      :maximun => 64,
    },
  })

  has_secure_password
end
