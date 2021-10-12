class Image < ApplicationRecord

  @member_id_list = Member.select(:id).all.map do | member |
    next member.id.to_i
  end

  p "This is in Image Model ---->", @member_id_list

  validates :member_id, {
    :presence => true,
    :length => {
      :minimum => 1,
    },
    :inclusion => {
      # membersテーブルに存在するmember_idであることを保証する
      :in => @member_id_list
    }
  }
end
