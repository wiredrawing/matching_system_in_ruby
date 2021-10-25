class Log < ApplicationRecord

  # Memberテーブルとのリレーション
  has_one :from_member, :class_name => "Member", :foreign_key => :id, :primary_key => :from_membe_id
  has_one :to_member, :class_name => "Member", :foreign_key => :id, :primary_key => :to_membe_id
end
