class Image < ApplicationRecord




  validates :member_id, {
    :presence => true,
    :length => {
      :minimum => 1,
    },
    :inclusion => {
      :in => Member.select(:id).all.map do | member |
                next member.id.to_i
              end
    }
  }
end
