class Like < ApplicationRecord
  # 差し出し元member_id
  belongs_to(:from_member, :class_name => "Member", :foreign_key => :from_member_id)
  belongs_to(:to_member, :class_name => "Member", :foreign_key => :to_member_id)
  validates(:to_member_id, {
    :presence => true,
    :inclusion => {
      :in => lambda do
        members = Member.select(:id).where(
          {
            :is_registered => UtilitiesController::BINARY_TYPE[:on],
          }
        )
        member_id_list = Array.new()
        members.each do |member|
          member_id_list.push(member.id)
        end
        return member_id_list
      end.call,
    },
  })

  validates(:from_member_id, {
    :presence => true,
    :inclusion => {
      :in => lambda do
        members = Member.select(:id).where(
          {
            :is_registered => UtilitiesController::BINARY_TYPE[:on],
          }
        )
        member_id_list = Array.new()
        members.each do |member|
          member_id_list.push(member.id)
        end
        return member_id_list
      end.call,
    },
  })
end
