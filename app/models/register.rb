class Register < ApplicationRecord
  self.table_name = "members"

  # emailバリデーション
  validates(:email, {
    :presence => true,
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "メールアドレスはは1文字以上512文字以内で入力して下さい",
    },
    :uniqueness => true,
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
  validates :gender, {
    :presence => true,
    :length => {
      :minimum => 0,
    },
  }
end
