class Footprint < ApplicationRecord
  has_one :from_member, :class_name => "Member", :primary_key => :from_member_id, :foreign_key => :id
end
