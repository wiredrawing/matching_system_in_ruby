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

  # 引数にわたしたメンバー同士がマッチしているかどうか
  def self.is_matching?(from_member_id = 0, to_member_id = 0)
    # cable用
    @matching_token = TokenForApi.make_random_token(128)
    match = self.where({
      :from_member_id => from_member_id,
      :to_member_id => to_member_id,
    }).or(self.where({
      :from_member_id => to_member_id,
      :to_member_id => from_member_id,
    }))

    # マッチしている場合
    if match.length == 2
      response = match.update({
        :matching_token => @matching_token,
      })
      return true
    else
      return false
    end
  end

  # 指定したユーザーがマッチングしたユーザー一覧を取得する
  def self.fetch_matching_members(member_id, excluded_members = [])
    # Fetch likes which logged in user send.
    informing_likes = self.select(:to_member_id).where({
      :from_member_id => member_id,
    }).to_a.map do |like|
      next like.to_member_id.to_i
    end

    # ログインユーザーがいいねしたメンバーが自身をいいねしているかどうか
    getting_members = self.select(:from_member_id).where({
      :to_member_id => member_id,
    }).to_a.map do |like|
      next like.from_member_id.to_i
    end

    # 双方いいねしている場合かつ､ブロックしてない且つされていないメンバーを取得
    matching_members = getting_members & informing_likes
    matching_members = Member.where({
      :id => matching_members,
    }).and(
      Member.where.not({
        :id => excluded_members,
      })
    )
    return (matching_members)
  end
end
