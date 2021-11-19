class Url < ApplicationRecord
  has_one :from_member, :class_name => "Member", :foreign_key => :id, :primary_key => :member_id

  validates :url, {
    :presence => {
      :message => "URL情報は必須項目です",
    },
  }

  validates :member_id, {
    :presence => {
      :message => "送信者IDは必須項目です",
    },
  # :inclusion => {
  #   :in => @member_id_list,
  # },
  }
end
