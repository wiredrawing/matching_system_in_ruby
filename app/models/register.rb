class Register < ApplicationRecord
  self.table_name = "members"

  # 任意の処理で指定のカラムをバリデーションする
  validates_each :email do |object, attr, value|
    # メールアドレスをすべて小文字に変換
    value = value.downcase

    member = self.find_by ({
      :email => value,
      :is_registered => UtilitiesController::BINARY_TYPE[:on],
    })

    # 既に本登録完了済みのメールアドレスの場合はエラーメッセージを追加する
    if member != nil
      object.errors.add(attr, "このメールアドレスは使用できません")
      next false
    end
    next true
  end

  # emailバリデーション
  validates(:email, {
    :presence => {
      :message => "メールアドレスは必須項目です",
    },
    :length => {
      :minimum => 5,
      :maximum => 512,
      :message => "メールアドレスはは1文字以上512文字以内で入力して下さい",
    },
  })

  # display_name(本名とは違うニックネーム表示用)
  validates :display_name, {
    :presence => {
      :message => "ニックネームは必須項目です",
    },
    :length => {
      :minimum => 1,
      :maximum => 128,
      :message => "ニックネームは5文字以上128文字以内で入力して下さい",
    },
  }

  # 性別
  validates :gender, {
    :presence => true,
    :length => {
      :minimum => 1,
    },
    :inclusion => {
      # mapメソッドで1以上の値で構成された配列を返却する
      :in => UtilitiesController.gender_id_list,
      :message => "性別は未設定以外を選択して下さい",
    },
  }
end
