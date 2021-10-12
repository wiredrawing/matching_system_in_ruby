module RegisterHelper

  # ランダムなトークンを作成する
  def make_random_token(size = 64)

    # トークンの最大長は最低16文字とする
    if size < 16
      size = 16
    end

    # 返却するトークン
    token = ""
    # 有効な文字群
    characters = []

    # 小文字のアルファベット
    small_alphabets = ("a".."z").to_a

    # 大文字のアルファベット
    big_alphabets = ("A".."Z").to_a
    # 数字
    numbers = (0..9).to_a

    characters = small_alphabets + big_alphabets + numbers

    characters.push("_").push(".").push("-").push("$")
    # p "charcters =====>", characters
    # 有効な文字群の長さ
    char_length = characters.length - 1
    # p char_length
    size.times do |index|
      random_index = rand(0..char_length)
      # p "radon_index ----->", random_index
      token += characters[random_index].to_s
    end

    return(token)
  end
end
