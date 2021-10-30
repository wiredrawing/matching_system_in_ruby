# Use upload image with api.
class FormImage
  include ActiveModel::Model

  attr_accessor :member_id, :extension, :token_for_api, :upload_file
  validates :member_id, {
    :presence => {
      :message => "画像送信者IDは必須項目です",
    },
    :inclusion => {
      # membersテーブルに存在するmember_idであることを保証する
      :in => lambda do
        members = Member.select(:id).where({
          :is_registered => UtilitiesController::BINARY_TYPE[:on],
        }).map do |member|
          next member.id
        end
      end[],
    },
  }

  # アップロードできるmimetypeを定義
  validates :extension, {
    :inclusion => {
      :in => UtilitiesController::EXTENSION_LIST.keys,
      :message => "画像ファイルのみアップロード可能です",
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
      :id => object.member_id,
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
