class Image < ApplicationRecord
  showable_for_scope = -> {
    where({
      :is_displayed => UtilitiesController::BINARY_TYPE[:on],
      :is_deleted => UtilitiesController::BINARY_TYPE[:off],
    })
  }

  scope :showable, showable_for_scope

  @member_id_list = Member.select(:id).all.map do |member|
    next member.id.to_i
  end

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
      :in => @member_id_list,
    },
  }

  # オブジェクトのmember.idからファイルのバイナリを取得する
  def fetch_file_path

    # 画像がアップロードされた日付
    Time.zone = "Asia/Tokyo"

    # selfからアップロードされた日時を取得する
    uploaded_at = self.uploaded_at.to_time

    # 画像のアップロード先ディレクトリ
    uploaded_path = Hash.new
    uploaded_path[:year] = uploaded_at.strftime "%Y"
    uploaded_path[:month] = uploaded_at.strftime "%m"
    uploaded_path[:day] = uploaded_at.strftime "%d"
    uploaded_path[:hour] = uploaded_at.strftime "%H"
    uploaded_path[:minute] = uploaded_at.strftime "%M"

    # ファイルコピー先のディレクトリを確定
    file_path = "storage/uploads/" +
                uploaded_path[:year] + "/" +
                uploaded_path[:month] + "/" +
                uploaded_path[:day] + "/" +
                uploaded_path[:hour] + "/" +
                self.id
    file_path = Rails.root.join file_path
    p "file_path =====>", file_path
    # ファイル保管場所パスを返却
    return file_path
  end

  def owner_image_url
    return api_image_owner_show_url(:id => self.id)
  end

  def member_image_url
    return api_image_show_url(:id => self.id, :member_id => self.member_id)
  end

  def display_status
    if self.is_displayed == UtilitiesController::BINARY_TYPE[:on]
      return "表示中"
    else
      return "非表示中"
    end
  end
end
