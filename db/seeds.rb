# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def make_random_birthday
  year_list = (1950..2020).map { |year|
    next year
  }
  month_list = (1..12).map do |month|
    next month
  end
  day_list = (1..31).map do |day|
    next day
  end
  birthday = "#{year_list.shuffle[0]}-#{month_list.shuffle[0]}-#{day_list.shuffle[0]}"
  return birthday
end

# 女性メンバーの登録処理
(1..10000).each do |index|
  index = index.to_s
  # 女性メンバーのSeedデータ
  member = Member.new({
    :email => "woman" + index + "@gmail.com",
    :display_name => "女性" + index + "表示名",
    :family_name => "女性" + index + " 名字",
    :given_name => "女性" + index + "名前",
    :gender => 2,
    :height => 150,
    :weight => 50,
    :birthday => make_random_birthday(),
    :salary => 250,
    :message => "女性#{index} のメッセージ",
    :memo => "女性#{index} のメモ",
    :password => "AAAAaaaa1234",
    :password_confirmation => "AAAAaaaa1234",
    :is_registered => UtilitiesController::BINARY_TYPE[:on],
    :token => "from_seed",
    :native_language => 1,
  })
  if (member.validate() == true)
    member.save()
  else
    pp member.errors.messages
  end
end

# 男性メンバーの登録処理
(1..10000).each do |index|
  index = index.to_s
  # 男性メンバーのseedデータ
  member = Member.new({
    :email => "guy1#{index}@gmail.com",
    :display_name => "男性#{index}表示名",
    :family_name => "男性#{index}名字",
    :given_name => "男性#{index}名前",
    :gender => 1,
    :height => 150,
    :weight => 50,
    :birthday => make_random_birthday(),
    :salary => 250,
    :message => "This is message of sample guy1",
    :memo => "This is memo",
    :password => "AAAAaaaa1234",
    :password_confirmation => "AAAAaaaa1234",
    :is_registered => UtilitiesController::BINARY_TYPE[:on],
    :token => "from_seed",
    :native_language => 1,
  })

  if (member.validate() == true)
    member.save()
  else
    pp member.errors.messages
  end
end
