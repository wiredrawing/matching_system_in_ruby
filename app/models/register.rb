class Register < ApplicationRecord
  self.table_name = "members"

  # 任意の処理で指定のカラムをバリデーションする
  validates_each :email do |object, attr, value|
    _member = self.find_by ({
      :email => value,
      :is_registered => UtilitiesController::BINARY_TYPE[:on],
    })

    # 既に本登録完了済みのメールアドレスの場合はエラーメッセージを追加する
    if _member != nil
      object.errors.add(attr, "このメールアドレスは使用できません")
    end
    next true
  end

  # emailバリデーション
  validates(:email, {
    :presence => {
      :message => "メールアドレスは必須項目です",
    },
    :length => {
      :minimum => 5,
      :maximum => 512,
      :message => "メールアドレスはは1文字以上512文字以内で入力して下さい",
    },
  # # 独自性の追加(※ memberテーブルに既に存在する場合はエラーとする)
  # :uniqueness => {
  #   :message => lambda do |object, data|
  #     print("validates->:uniquenes->:message内のlambda関数内処理")
  #     p "uniquenessのmessegeラムダ内"
  #     p "object ------>", object
  #     p "data--------->", data
  #     message = "このメールアドレスは現在使用できません"
  #     return false
  #   end,
  # # :message => "このメールアドレスは使用できません",
  # },
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
    :inclusion => {
      # mapメソッドで1以上の値で構成された配列を返却する
      :in => (lambda do
        gender_id_list = []
        MembersController::GENDER_LIST.map do |gender|
          gender_id = gender[:id]
          if gender_id > 0
            gender_id_list.push(gender[:id])
          end
        end
        # 0以外の定数数値を返却する
        return gender_id_list
      end)[],
      :message => "性別は未設定以外を選択して下さい",
    },
  }

  gender_list = MembersController::GENDER_LIST.map do |gender|
    gender_id = gender[:id]
    if gender_id > 0
      next gender[:id]
    end
  end
end
