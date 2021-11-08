class Timeline < ApplicationRecord

  # 送信者
  has_one :from_member, :class_name => "Member", :foreign_key => :id, :primary_key => :from_member_id

  # 受信者
  has_one :to_member, :class_name => "Member", :foreign_key => :id, :primary_key => :to_member_id

  # メッセージアクション
  has_one :message, :class_name => "Message", :foreign_key => :id, :primary_key => :message_id

  # 画像アクション
  has_one :image, :class_name => "Image", :foreign_key => :id, :primary_key => :image_id

  # URLアクション
  has_one :url, :class_name => "Url", :foreign_key => :id, :primary_key => :url_id

  public

  # 指定したメンバー間のタイムライン
  def timelines(to_member_id = 0, offset = 0, limit = 10)
    # 指定したメンバーのみのやり取りを取得
    @timelines = self.select(:id).where({
      :from_member_id => self.id,
      :to_member_id => to_member_id,
    }).or(self.where({
      :from_member_id => to_member_id,
      :to_member_id => self.id,
    })).includes(
      :message,
      :image,
      :url,
      :from_member,
      :to_member,
    )
      .order(:created_at => :desc)
      .limit(limit)
      .offset(offset)

    if timelines.first == nil
      return nil
    end
    return @timelines
  rescue => error
    logger.debug error.message
    return nil
  end
end
