class Footprint < ApplicationRecord
  paginates_per 10
  has_one :from_member, :class_name => "Member", :primary_key => :from_member_id, :foreign_key => :id

  # アクセス禁止ユーザの足跡は除外する
  scope :valid_footprints, ->(current_user) {
          forbidden_members = current_user.forbidden_members()
          where.not("from_member_id", forbbiden_members)
        }
end
