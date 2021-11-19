# Use upload image with api.
class TokenCheck
  include ActiveModel::Model

  attr_accessor :id, :token_for_api

  validates :id, {
    :presence => {
      :message => "画像送信者IDは必須項目です",
    },
    :inclusion => {
      # membersテーブルに存在するmember_idであることを保証する
      :in => (lambda do
        members = Member.select(:id).where({
          :is_registered => UtilitiesController::BINARY_TYPE[:on],
        }).to_a.map do |member|
          next member.id
        end
        return members
      end).call,
      :message => "不正なメンバーIDです",
    },
  }

  # Is valid the token for api which you have recieved?
  validates :token_for_api, {
    :presence => {
      :message => "APIリクエスト用トークンは必須項目です",
    },
  }

  validates_each :token_for_api do |object, attribute, data|
    member = Member.find_by({
      :id => object.id,
      :token_for_api => data,
    })
    if member == nil
      object.errors.add(attribute, "APIリクエスト用トークンが不正です")
      next false
    end
    # If the combination of id and token is valid so return true.
    next true
  end
end
