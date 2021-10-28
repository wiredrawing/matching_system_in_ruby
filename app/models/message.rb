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
  #   :in => lambda do
  #     members = Member.where({
  #       :is_registered => UtilitiesController::BINARY_TYPE[:on],
  #     }).to_a.map do |member|
  #       next member.id
  #     end
  #   end.call,
  # },
  }
end
