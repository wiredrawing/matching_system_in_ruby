module MembersHelper
  private

  def set_gender_list
    # とりあえず仮
    @genders = [
      ["未設定", 0],
      ["男性", 1],
      ["女性", 2],
    ]
    p "MemberHelper の実行"

    @binary_type = {
      :on => 1,
      :off => 0,
    }
  end
end
