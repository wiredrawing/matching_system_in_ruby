class Decline < ApplicationRecord

  # 任意のバリデート処理を指定のリクエストデータに対して行う
  validates_each :to_member_id do |object, attr, data|
    # print("validates_each in Decline model --------------------->")
    already_blocks = false
    _decline = self.exists?({
      :from_member_id => object.from_member_id,
      :to_member_id => data,
    })

    if _decline == true
      object.errors.add(attr, "既にブロック済みです")
    end
    next true
  end

  validates :to_member_id, {
    :presence => true,
    :inclusion => {
      :in => (-> {
        members = Member.select(:id).all().map do |member|
          next member.id.to_i
        end
        return members
      }).call,
    },
  }

  validates :from_member_id,
            :presence => true,
            :inclusion => {
              :in => (-> {
                members = Member.select(:id).all().map do |member|
                  next member.id.to_i
                end
                return members
              }).call,
            }

  # ログイン中ユーザーのブロック一覧画面でのみ使用する
  # 指定したメンバーがブロックしているメンバー一覧を取得する
  def self.fetch_blocking_members(member_id)
    # 引数に指定したユーザーがブロックしているユーザー一覧
    declining_members = self.select(:to_member_id).where({
      :from_member_id => member_id,
    }).map do |decline|
      next decline.to_member_id
    end

    # ブロック中ユーザーの中からはブロックされているユーザーは除外する
    declined_members = self.select(:from_member_id).where({
      :to_member_id => member_id,
    }).map do |decline|
      next decline.from_member_id
    end

    # ブロックしているユーザーのみ
    declining_members = declining_members - declined_members
    declining_members = Member.where({
      :id => declining_members,
    })
    return (declining_members)
  end

  # 指定したユーザーをブロックしているメンバーリスト
  def self.members_blocking_you(member_id)
    members_blocking_you = self.select(:from_member_id).where({
      :to_member_id => member_id,
    })
    members = Member.where({
      :id => members_blocking_you,
    })
    return members
  end

  # 指定したユーザーがブロックしているメンバーリスト
  def self.members_you_block(member_id)
    members_you_block = self.select(:to_member_id).where({
      :from_member_id => member_id,
    })
    members = Member.where({
      :id => members_you_block,
    })
    return members
  end
end
