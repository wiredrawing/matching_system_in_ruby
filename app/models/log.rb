class Log < ApplicationRecord

  # Define the column named action_name on log table.
  attribute :from_member
  attribute :action_name
  # Memberテーブルとのリレーション
  has_one :from_member, :class_name => "Member", :foreign_key => :id, :primary_key => :from_member_id
  has_one :to_member, :class_name => "Member", :foreign_key => :id, :primary_key => :to_member_id

  # Validate from_member_id.
  validates :from_member_id, {
    :presence => {
      :message => "送信者IDは必須項目です",
    },
    :inclusion => {
      :in => lambda do
        members = Member.select(:id).to_a.map do |member|
          next member.id
        end
        return members
      end.call(),
      :message => "送信者IDは有効なIDを指定して下さい",
    },
  }

  validates :to_member_id, {
    :presence => {
      :message => "送信先IDは必須項目です",
    },
    :inclusion => {
      :in => lambda do
        members = Member.select(:id).to_a.map do |member|
          next member.id
        end
        return members
      end.call(),
      :message => "送信先IDは有効なIDを指定して下さい",
    },
  }

  def action_name
    if UtilitiesController::ACTION_STRING_LIST.keys.include?(self.action_id) != true
      return ""
    end
    return UtilitiesController::ACTION_STRING_LIST[self.action_id]
  end
end
