class Image < ApplicationRecord
  before_validation :owner_image_url, :image_url

  # 画像の所有者
  # has_oneの場合
  has_one :member, :class_name => "Member", :foreign_key => :id, :primary_key => :member_id
  # belongs_toの場合
  belongs_to :member_blongs_to, :class_name => "Member", :foreign_key => :member_id, :primary_key => :id

  # 動的に追加するプロパティ
  attribute :owner_image_url
  attribute :image_url
  attribute :image_url_to_active
  attribute :image_url_to_update
  attribute :image_url_to_delete
  attribute :image_url_to_upload
  attribute :display_status
  attribute :updated_at_string
  attribute :created_at_string

  showable_for_scope = -> {
    where({
      :is_displayed => UtilitiesController::BINARY_TYPE[:on],
      :is_deleted => UtilitiesController::BINARY_TYPE[:off],
    })
  }

  scope :showable, showable_for_scope

  # アップロードできるmimetypeを定義
  validates :extension, {
    :inclusion => {
      :in => UtilitiesController::EXTENSION_LIST.keys,
      :message => "画像ファイルのみアップロード可能です",
    },
  }

  validates :member_id, {
    :presence => true,
    :length => {
      :minimum => 1,
    },
    :inclusion => {
      # membersテーブルに存在するmember_idであることを保証する
      :in => (-> do
        members = Member.select(:id).all().map do |member|
          next member.id
        end
        next members
      end).call(),
    },
  }

  # オブジェクトのmember.idからファイルのバイナリを取得する
  def fetch_file_path

    # 画像がアップロードされた日付
    Time.zone = "Asia/Tokyo"

    # selfからアップロードされた日時を取得する
    uploaded_at = self.uploaded_at.to_time

    uploaded_path = self.uploaded_at.to_time.strftime "storage/uploads/%Y/%m/%d/%H/#{self.filename}"

    # # 画像のアップロード先ディレクトリ
    # uploaded_path = Hash.new
    # uploaded_path[:year] = uploaded_at.strftime "%Y"
    # uploaded_path[:month] = uploaded_at.strftime "%m"
    # uploaded_path[:day] = uploaded_at.strftime "%d"
    # uploaded_path[:hour] = uploaded_at.strftime "%H"
    # uploaded_path[:minute] = uploaded_at.strftime "%M"

    # # ファイルコピー先のディレクトリを確定
    # file_path = "storage/uploads/" +
    #             uploaded_path[:year] + "/" +
    #             uploaded_path[:month] + "/" +
    #             uploaded_path[:day] + "/" +
    #             uploaded_path[:hour] + "/" +
    #             self.filename

    file_path = Rails.root.join uploaded_path
    # ファイル保管場所パスを返却(※文字列型で返却)
    return file_path
  end

  # URL to show the public image .
  def image_url
    image_url = api_public_image_url(:id => self.id, :token => self.token, :query => self.updated_at_string)
    return image_url
  end

  # URL to show the private image which owner doesn't allow to.
  def owner_image_url
    image_url = api_private_image_url(
      :id => self.id,
      :member_id => self.member_id,
      :token_for_api => self.member.token_for_api,
      :query => self.updated_at,
    )
    return image_url
  end

  def image_url_to_active
    image_url_to_active = active_image_url(:id => self.id)
    return image_url_to_active
  end

  def image_url_to_update
    image_url_to_update = api_image_update_url({ :id => self.id })
    return image_url_to_update
  end

  def image_url_to_delete
    image_url_to_delete = mypage_delete_image_url()
    return image_url_to_delete
  end

  def image_url_to_delete
    image_url_to_delete = api_image_delete_url(:id => self.id)
    return image_url_to_delete
  end

  def image_url_to_upload
    image_url_to_upload = api_image_upload_url()
    return image_url_to_upload
  end

  def display_status
    if self.is_displayed == UtilitiesController::BINARY_TYPE[:on]
      return "表示中"
    else
      return "非表示中"
    end
  end

  # 画像アップロード日時
  def created_at_string
    if (self.created_at != nil)
      return self.created_at.strftime("%Y-%m-%dT%H-%M-%S")
    end
    return nil
  end

  # 画像更新日時
  def updated_at_string
    if (self.updated_at != nil)
      return self.updated_at.strftime("%Y-%m-%dT%H-%M-%S")
    end
    return nil
  end
end
