# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# 女性メンバーのSeedデータ
member = Member.new({
  :email => "woman1@gmail.com",
  :display_name => "woman1",
  :family_name => "woman1_family_name",
  :given_name => "woman1_given_name",
  :gender => 2,
  :height => 150,
  :weight => 50,
  :birthday => "1988-12-25",
  :salary => 250,
  :message => "This is message of sample woman1",
  :memo => "This is memo",
  :password => "AAAAaaaa1234",
  :password_confirmation => "AAAAaaaa1234",
  :is_registered => UtilitiesController::BINARY_TYPE[:on],
  :token => "from_seed",
  :native_language => 1,
})
if (member.validate() == true)
  member.save()
end

Member.create({
  :email => "woman2@gmail.com",
  :display_name => "woman2",
  :family_name => "woman2_family_name",
  :given_name => "woman2_given_name",
  :gender => 2,
  :height => 150,
  :weight => 50,
  :birthday => "1987-12-25",
  :salary => 250,
  :message => "This is message of sample woman2",
  :memo => "This is memo",
  :password => "AAAAaaaa1234",
  :password_confirmation => "AAAAaaaa1234",
  :is_registered => UtilitiesController::BINARY_TYPE[:on],
  :token => "from_seed",
  :native_language => 1,
})

Member.create({
  :email => "woman3@gmail.com",
  :display_name => "woman3",
  :family_name => "woman3_family_name",
  :given_name => "woman3_given_name",
  :gender => 2,
  :height => 150,
  :weight => 50,
  :birthday => "1990-12-25",
  :salary => 250,
  :message => "This is message of sample woman3",
  :memo => "This is memo",
  :password => "AAAAaaaa1234",
  :password_confirmation => "AAAAaaaa1234",
  :is_registered => UtilitiesController::BINARY_TYPE[:on],
  :token => "from_seed",
  :native_language => 1,
})

Member.create({
  :email => "woman4@gmail.com",
  :display_name => "woman4",
  :family_name => "woman4_family_name",
  :given_name => "woman4_given_name",
  :gender => 2,
  :height => 150,
  :weight => 50,
  :birthday => "1995-12-25",
  :salary => 250,
  :message => "This is message of sample woman4",
  :memo => "This is memo",
  :password => "AAAAaaaa1234",
  :password_confirmation => "AAAAaaaa1234",
  :is_registered => UtilitiesController::BINARY_TYPE[:on],
  :token => "from_seed",
  :native_language => 1,
})

# 男性メンバーのseedデータ
member = Member.new({
  :email => "guy1@gmail.com",
  :display_name => "guy1 man name",
  :family_name => "guy1_family_name",
  :given_name => "guy1_given_name",
  :gender => 1,
  :height => 150,
  :weight => 50,
  :birthday => "1988-12-25",
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
  p member.errors
end

Member.create({
  :email => "guy2@gmail.com",
  :display_name => "guy2 man name",
  :family_name => "guy2_family_name",
  :given_name => "guy2_given_name",
  :gender => 1,
  :height => 150,
  :weight => 50,
  :birthday => "1987-12-25",
  :salary => 250,
  :message => "This is message of sample guy2",
  :memo => "This is memo",
  :password => "AAAAaaaa1234",
  :password_confirmation => "AAAAaaaa1234",
  :is_registered => UtilitiesController::BINARY_TYPE[:on],
  :token => "from_seed",
  :native_language => 1,
})

Member.create({
  :email => "guy3@gmail.com",
  :display_name => "guy3 man name",
  :family_name => "guy3_family_name",
  :given_name => "guy3_given_name",
  :gender => 1,
  :height => 150,
  :weight => 50,
  :birthday => "1990-12-25",
  :salary => 250,
  :message => "This is message of sample guy3",
  :memo => "This is memo",
  :password => "AAAAaaaa1234",
  :password_confirmation => "AAAAaaaa1234",
  :is_registered => UtilitiesController::BINARY_TYPE[:on],
  :token => "from_seed",
  :native_language => 1,
})

Member.create({
  :email => "guy4@gmail.com",
  :display_name => "guy4 man name",
  :family_name => "guy4_family_name",
  :given_name => "guy4_given_name",
  :gender => 1,
  :height => 150,
  :weight => 50,
  :birthday => "1995-12-25",
  :salary => 250,
  :message => "This is message of sample guy4",
  :memo => "This is memo",
  :password => "AAAAaaaa1234",
  :password_confirmation => "AAAAaaaa1234",
  :is_registered => UtilitiesController::BINARY_TYPE[:on],
  :token => "from_seed",
  :native_language => 1,
})
