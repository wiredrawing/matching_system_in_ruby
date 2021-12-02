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
          :is_registered => Constants::Binary::Type[:on],
        }).map do |member|
          next member.id
        end
      end[],
    },
  }

  # Is valid the token for api which you have recieved?
  validates :token_for_api, {
    :presence => {
      :message => "APIリクエスト用トークンは必須項目です",
    },
  }

  validates_each :extension do |object, attribute, data|
    if data.nil?
      object.errors.add(attribute, "ファイルアップロードは必須項目です")
      next false
    end

    # ファイルサイズを検証
    max_filesize = data.size
    if max_filesize > UtilitiesController::UPLOADABLE_SIZE
      object.errors.add(attribute, "ファイルサイズは3MB以下にして下さい")
      next false
    end

    # ファイルの拡張子を検証
    content_type = data.content_type.to_s
    if Constants::Extension::LIST.keys.include?(content_type) != true
      object.errors.add(attribute, "無効なファイル拡張子です")
      next false
    end
    next true
  end

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
