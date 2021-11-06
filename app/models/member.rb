class Member < ApplicationRecord
  attribute :forbidden_members
  attribute :informing_valid_likes
  attribute :getting_valid_likes
  # パスワード処理
  has_secure_password
  # ページング処理
  paginates_per 2

  # リレーションの関連付け
  # もらったいいいね
  has_many(:getting_likes, :class_name => "Like", :foreign_key => :to_member_id, :primary_key => :id)
  # 贈ったいいね
  has_many(:informing_likes, :class_name => "Like", :foreign_key => :from_member_id, :primary_key => :id)
  # 自身をブロックしているユーザー
  has_many(:declined, :class_name => "Decline", :foreign_key => :to_member_id)
  # 自身がブロックしているユーザー
  has_many(:declining, :class_name => "Decline", :foreign_key => :from_member_id)
  # メンバーが公開中にしているアップロード画像
  has_many(:showable_images, lambda do
    where({
      :is_displayed => UtilitiesController::BINARY_TYPE[:on],
      :is_deleted => UtilitiesController::BINARY_TYPE[:off],
    }).order(:created_at => :desc)
  end, **{
         :class_name => "Image",
         :foreign_key => :member_id,
       })

  # メンバーがアップロードした全画像
  # 並び順sqlをlambda関数で渡す
  _anonymous = lambda do
    self.order({
      :created_at => :desc,
      :updated_at => :desc,
    })
  end
  has_many(:all_images, _anonymous, **{
                                      :class_name => "Image",
                                      :foreign_key => :member_id,
                                    })

  # 自身に送信されたメッセージ一覧を取得する
  has_many :getting_timeline,
           -> {
             order(:created_at => :desc)
           },
           :class_name => "Timeline",
           :foreign_key => :to_member_id,
           :primary_key => :id

  # 自身が送信したメッセージ一覧を取得する
  has_many :informing_timeline,
           -> {
             order(:created_at => :desc)
           },
           :class_name => "Timeline",
           :foreign_key => :from_member_id,
           :primary_key => :id

  # いいねを贈ることができる異性のメンバー一覧を取得する
  def self.hetero_members(current_user = nil, exculded_members = [])
    print("ログインユーザーとは性別のことなるメンバー一覧を取得する")
    pp(current_user)
    # ブロックしているユーザー
    begin
      @members = self.where({
        :is_registered => UtilitiesController::BINARY_TYPE[:on],
      }).and(
        self.where.not({
          :id => current_user.id,
        }).and(
          self.where.not({
            :gender => current_user.gender,
          })
        )
      ).and(
        self.where.not({
          :id => exculded_members,
        })
      )
      return(@members)
    rescue => error
      puts("Happen error------------------>")
      puts(error)
      # 例外発生時は[nil]を返却
      return(nil)
    end
  end

  # 指定したmember_idのユーザーをログイン中ユーザーが閲覧できる場合のみ
  # member情報を返却する
  def self.showable_member(current_user = nil, member_id = 0)
    _member = self.where({
      :is_registered => UtilitiesController::BINARY_TYPE[:on],
      :id => member_id,
    }).and(
      self.where.not({
        :id => current_user.id,
      }).or(
        self.where.not({
          :gender => current_user.gender,
        })
      )
    ).first()

    if _member == nil
      raise StandardError.new("指定したユーザーが見つかりませんでした")
    end
    return(_member)
  rescue => error
    puts("[例外発生-------------------------------------------------]")
    print("error ----------->", error)
    return nil
  end

  # 特定のキーに対して､任意のバリデー処理を実行させる
  validates_each(:token) do |object, attribute, data|
    if (object.token == "from_seed")
      next true
    else
      _member = Member.where({
        :token => data,
        :id => object.id,
      }).first

      if (_member == nil)
        object.errors.add(attribute, "仮登録トークンが不正です")
      end
      next true
    end
  end

  # 性別は初期登録時から変更させない
  validates_each :gender do |object, attribute, data|
    # Get the member info while operating.
    member = Member.where({
      :token => object.token,
      :id => object.id,
    }).first()

    if member == nil
      object.errors.add(attribute, "仮登録トークンが不正です")
      next false
    end
    if data.to_i != member.gender
      object.errors.add(attribute, "性別は変更できません")
      next false
    end
    # Exit successfully.
    next true
  end

  # emailバリデーション
  validates(:email, {
    :presence => {
      :message => "メールアドレスは必須項目です",
    },
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "メールアドレスはは1文字以上512文字以内で入力して下さい",
    },
  })

  # display_name(本名とは違うニックネーム表示用)
  validates :display_name, {
    :presence => {
      :message => "ニックネームは必須項目です",
    },
    :length => {
      :minimum => 5,
      :maximum => 128,
      :message => "ニックネームは5文字以上128文字以内で入力して下さい",
    },
  }

  # 性別
  validates(:gender, {
    :presence => {
      :message => "性別は必須項目です",
    },
    :length => {
      :minimum => 0,
    },
    :inclusion => {
      # mapメソッドで1以上の値で構成された配列を返却する
      :in => UtilitiesController.gender_id_list,
      :message => "性別は未設定以外を選択して下さい",
    },
  })

  validates :given_name, {
    :presence => {
      :message => "名は必須項目です",
    },
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "名前は1文字以上512文字以内で入力して下さい",
    },
  }

  validates :family_name, {
    :presence => {
      :message => "姓は必須項目です",
    },
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "名字は1文字以上512文字以内で入力して下さい",
    },
  }

  # パスワード
  validates :password, {
    :presence => {
      :message => "パスワードは必須項目です",
    },
    :length => {
      :minimum => 10,
      :maximun => 64,
    },
    :on => :member_update_password,
  }

  # パスワード確認用
  validates (:password_confirmation), ({
    :presence => {
      :message => "確認用パスワードは必須項目です",
    },
    :length => {
      :minimum => 10,
      :maximun => 64,
    },
    :on => :member_update_password,
  })

  # 文字列としての性別を取得する
  def gender_string()
    # 性別定数をループする
    UtilitiesController::GENDER_LIST.each do |gender|
      break gender[:value] if gender[:id] == self.gender
    end
  end

  ##########################################
  # いいねを贈っているかどうか
  ##########################################
  def like?(member_id = 0)
    like = Like.where({
      :from_member_id => self.id,
      :to_member_id => member_id,
    }).first()

    if (like != nil)
      logger.debug "#{self.id}は#{member_id}にいいねをしています"
      return true
    end
    return false
  end

  ##########################################
  # いいねされているかどうか
  ##########################################
  def is_liked?(member_id = 0)
    like = Like.where({
      :from_member_id => member_id,
      :to_member_id => self.id,
    }).first()

    if (like != nil)
      logger.debug "#{self.id}は#{member_id}にいいねされています"
      return true
    end
    return false
  end

  ##########################################
  # 指定したユーザーとマッチしているかどうか?
  ##########################################
  def match_you?(member_id)
    # Have you gotten likes from member_id?
    getting_like = self.getting_likes.where({
      :from_member_id => member_id,
      :to_member_id => self.id,
    }).first()

    # Have you send like to member_id?
    informing_likes = self.informing_likes.where({
      :from_member_id => self.id,
      :to_member_id => member_id,
    }).first()

    if getting_like != nil && informing_likes != nil
      return true
    else
      return false
    end
  end

  ##########################################
  # 指定したユーザーにブロックされてないかしていないか?
  # You can browse member info which you selected, if return true on this method.
  # if return value is false, you cannot browse this member info.
  ##########################################
  def browsable?(member_id)

    # Does login user decline selected member?
    browsable = self.declined.where({
      :from_member_id => member_id,
    }).first()
    pp "# Does login user decline selected member?"
    pp(browsable)
    if browsable != nil
      return false
    end

    # Is login user  declined by selected member?
    browsable = self.declining.where({
      :to_member_id => member_id,
    }).first()

    pp "# Is login user  declined by selected member?"
    pp(browsable)
    if browsable != nil
      return false
    end

    return true
  end

  # 自身が贈った現時点で有効なlike
  def informing_valid_likes
    puts("valid_likes--------------------->")
    valid_likes = Array.new()
    likes = self.informing_likes.map do |like|
      next like.to_member_id
    end
    valid_likes = likes - self.forbidden_members
    # p("贈った有効ないいね")
    # pp(valid_likes)
    return valid_likes
  end

  # 自身がもらった現時点で有効なlike
  def getting_valid_likes
    puts("valid_likes--------------------->")
    valid_likes = Array.new()
    likes = self.getting_likes.map do |like|
      next like.from_member_id
    end
    valid_likes = likes - self.forbidden_members
    # p("もらった有効ないいね")
    # pp(valid_likes)
    return valid_likes
  end

  # アクセスできないメンバー一覧
  def forbidden_members
    forbidden_members = Array.new
    # ブロックしているユーザー
    declining = self.declining.map do |d|
      next d.to_member_id
    end
    # ブロックされているユーザー
    declined = self.declined.map do |d|
      next d.from_member_id
    end
    forbidden_members = declined + declining
  end
end
