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
  def is_matching?(from_member_id = 0, to_member_id = 0)
    puts("[Member#is_match ----------------------------------------]")
    begin
      # 送信元
      from_like = self.where :from_member_id => from_member_id, :to_member_id => to_member_id
      pp(from_like)
      # 送信先
      to_like = self.where :from_member_id => to_member_id, :to_member_id => from_member_id
      pp(to_like)
      if from_like.length == 1 && to_like.length == 1
        return true
      else
        return false
      end
    rescue => exception
      pp(exception)
      return false
    end
  end

  # 指定したユーザーがマッチングしたユーザー一覧を取得する
  def self.fetch_matching_members(member_id)
    # print("マッチング中ユーザー一覧を取得する")
    # いいねを贈ったmember_idの配列を作成
    informing_likes = self.select(:to_member_id).where({
      :from_member_id => member_id,
    }).to_a.map do |like|
      next like.to_member_id.to_i
    end

    # ログインユーザーがいいねしたメンバーが自身をいいねしているかどうか
    matching_members = self.select(:from_member_id).where({
      "to_member_id" => member_id,
      "from_member_id" => informing_likes,
    }).to_a.map do |like|
      # print("マッチング済みユーザー一覧を取得する")
      next like.from_member_id.to_i
    end

    # puts("以下､マッチング済みユーザー一覧")
    # p(matching_members)
    matching_members = Member.where({
      :id => matching_members,
    })
    return (matching_members)
  end
end
