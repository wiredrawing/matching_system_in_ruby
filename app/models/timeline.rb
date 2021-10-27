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
end
