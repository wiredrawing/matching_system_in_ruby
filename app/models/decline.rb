class Decline < ApplicationRecord

  # 任意のバリデート処理を指定のリクエストデータに対して行う
  validates_each :to_member_id do |object, attr, data|
    # print("validates_each in Decline model --------------------->")
    already_blocks = false
    _decline = self.exists?({
      :from_member_id => object.from_member_id,
      :to_member_id => data,
    })
    p _decline
    if _decline == true
      object.errors.add(attr, "既にブロック済みです")
    end
    next true
    # p(_decline)

    # p(object)
    # p(attr)
    # p(data)
  end

  validates :to_member_id, {
    :presence => true,
    :inclusion => {
      :in => (-> {
        p("----------------------------27")
        members = Member.select(:id).all().map do |member|
          next member.id.to_i
        end
        p(members)
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
end
