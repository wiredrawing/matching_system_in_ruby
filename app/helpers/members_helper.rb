module MembersHelper
  private

  def set_gender_list
    puts "性別リストを取得する--------------"
    # とりあえず仮
    @genders = [
      ["未設定", 0],
      ["男性", 1],
      ["女性", 2],
    ]
  end
end
