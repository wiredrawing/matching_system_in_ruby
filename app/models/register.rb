class Register < ApplicationRecord
  self.table_name = "members"

  # emailバリデーション
  validates(:email, {
    :presence => true,
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "メールアドレスはは1文字以上512文字以内で入力して下さい",
    },
    :uniqueness => true,
  })

  # display_name(本名とは違うニックネーム表示用)
  validates :display_name, {
    :presence => true,
    :length => {
      :minimum => 5,
      :maximum => 128,
      :message => "ニックネームは5文字以上128文字以内で入力して下さい",
    },
  }

  # 性別
  validates :gender, {
    :presence => true,
    :length => {
      :minimum => 0,
    },
  }

  def self.make_token(size = 64)
    small_alphabets = ("a".."z").to_a
    big_alphabets = ("A".."Z").to_a
    numbers = (0..9).to_a
    characters = small_alphabets + big_alphabets + numbers
    char_length = characters.length

    token = ""

    # ブロック内からは外部変数を参照できる
    size.times do |index|
      token += characters[rand(0..char_length)].to_s
      p characters[rand(0..char_length)].to_s
    end
    print "completed times"
    p token
    token
  end
end
