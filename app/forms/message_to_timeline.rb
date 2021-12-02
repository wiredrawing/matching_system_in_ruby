class MessageToTimeline
  include ActiveModel::Model

  attr_accessor :message, :from_member_id, :to_member_id, :token_for_api

  validates_each :token_for_api do |object, attribute, data|
    member = Member.where({
      :token_for_api => data,
      :id => object.from_member_id,
    }).first

    if member == nil
      object.errors.add(attribute, "APIリクエスト用トークンがマッチしません")
      next false
    end
    next true
  end

  validates :message, {
    :presence => {
      :message => "メッセージは必須項目です",
    },
  }

  # Validation member_id.
  validates :from_member_id, {
    :presence => {
      :message => "メッセージ送信者member_idは必須項目です",
    },
    :inclusion => {
      :in => lambda do
        members = Member.select(:id).where({
          :is_registered => Constants::Binary::Type[:on],
        }).to_a.map do |member|
          next member.id
        end
      end[],
      :message => "メッセージ送信者は必須項目です",
    },
  }

  validates :to_member_id, {
    :presence => {
      :message => "メッセージ送信者member_idは必須項目です",
    },
    :inclusion => {
      :in => lambda do
        members = Member.select(:id).where({
          :is_registered => Constants::Binary::Type[:on],
        }).to_a.map do |member|
          next member.id
        end
      end[],
      :message => "メッセージ受信者は必須項目です",
    },
  }

  validates :token_for_api, {
    :presence => {
      :message => "APIリクエスト用トークンは必須項目です",
    },
  }
end
