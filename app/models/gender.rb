class Gender < ApplicationRecord



  @genders = [
    {
      :key => 0,
      :value => "未設定",
    },
    {
      :key => 1,
      :value => "男性",
    },
    {
      :key => 2,
      :value => "女性",
    },
  ]
end
