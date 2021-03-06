class Timeline < ApplicationRecord

  # websocketで送信後
  # after_create_commit do
  #   TimelineBroadcastJob.perform_later(self)
  # end

  # 指定したマッチングでのやり取りを取得する
  scope :each_other, ->from_member_id, to_member_id {
          where({
            :from_member_id => from_member_id,
            :to_member_id => to_member_id,
          }).or(self.where({
            :from_member_id => to_member_id,
            :to_member_id => from_member_id,
          }))
        }

  # 送信者
  has_one :from_member, :class_name => "Member", :foreign_key => :id, :primary_key => :from_member_id

  # 受信者
  has_one :to_member, :class_name => "Member", :foreign_key => :id, :primary_key => :to_member_id

  # メッセージアクション
  has_one :message, :class_name => "Message", :foreign_key => :id, :primary_key => :message_id

  # 画像アクション
  has_one :image, -> do
            # ラムダ記法で記述
            where({
              :is_displayed => Constants::Binary::Type[:on],
              :is_deleted => Constants::Binary::Type[:off],
            })
          end, **{ :class_name => "Image", :foreign_key => :id, :primary_key => :image_id }

  # URLアクション
  has_one :url, :class_name => "Url", :foreign_key => :id, :primary_key => :url_id

  attribute :message
  attribute :from_member
  attribute :to_member
  attribute :image
  attribute :url
  attribute :created_at_string
  attribute :browsed

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

  def created_at_string()
    if self.created_at != nil
      return self.created_at.strftime("%Y年%m月%d日 %H時%M時%S秒")
    else
      return nil
    end
  end

  def browsed
    if self.is_browsed == Constants::Binary::Type[:on]
      return "既読"
    end
    return "未読"
  end
end
