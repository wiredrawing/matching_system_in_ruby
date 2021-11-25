class Message < ApplicationRecord

  # メッセージの入力内容のバリデーション
  validates :message, {
    :presence => {
      :message => "メッセージは必須項目です",
    },
    :length => {
      :minumum => 1,
      :maximum => 1024,
    },
  }

  # 発言者member_idのバリデーション
  validates :member_id, {
    :presence => {
      :message => "発言者member_idは必須項目です",
    },
  # :inclusion => {
  #   :in => self.registered_members,
  # },
  }
end
