# ログイン時にバリデーションを行うためのモデル
class Login < ApplicationRecord

  # model名がテーブル名と異なるため
  self.table_name = "members"

  # Laravelでいう無名関数でのバリデーション
  validates_each(:email) do |object, attribute, value|
    member = Member.find_by({
      # メールアドレスを小文字で検索
      :email => value.downcase,
      :is_registered => UtilitiesController::BINARY_TYPE[:on],
    })

    if member == nil
      object.errors.add(attribute, "メールアドレスが正しくありません")
      next false
    end
    next true
  end

  validates_each(:password) do |object, attribute, value|
    member = Member.find_by({
      # メールアドレスを小文字で検索
      :email => object.email.downcase,
      :is_registered => UtilitiesController::BINARY_TYPE[:on],
    })

    if (member == nil)
      object.errors.add(attribute, "パスワード認証に失敗しました")
      next false
    end
    response = member.authenticate(value)
    if (response)
      next true
    else
      object.errors.add(attribute, "パスワード認証に失敗しました")
      next false
    end
  end

  validates(:email, {
    :presence => {
      :message => "ログイン用メールアドレスは必須項目です",
    },
  })

  validates(:password, {
    :presence => {
      :message => "ログイン用パスワードは必須項目です",
    },
  })

  has_secure_password
end
