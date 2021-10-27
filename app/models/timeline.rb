class Timeline < ApplicationRecord

  # 自身が送信したメッセージ
  has_one :from_member, :class_name => "Member", :foreign_key => :id, :primary_key => :from_member_id

  # 自身が受信したメッセージ
  has_one :to_member, :class_name => "Member", :foreign_key => :id, :primary_key => :to_member_id
end
