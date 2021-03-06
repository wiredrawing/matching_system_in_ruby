class Member < ApplicationRecord
  attribute :forbidden_members
  # attribute :informing_valid_likes
  # attribute :getting_valid_likes
  attribute :timeline_created_at, :datetime
  attribute :native_language_string
  attribute :interested_languages_string
  # attribute :matching_members
  # attribute :year, :datetime
  # attribute :month, :datetime
  # attribute :day, :datetime
  # パスワード処理
  has_secure_password
  # ページング処理
  paginates_per 10

  attr_accessor :year, :month, :day, :age, :languages, :agree

  # -----------------------------------------------------------------
  # ここからリレーションの関連付け
  # -----------------------------------------------------------------
  # もらったいいいね
  has_many(:getting_likes, :class_name => "Like", :foreign_key => :to_member_id, :primary_key => :id) do
    def valid_likes(current_user)
      return where.not(:from_member_id => current_user.forbidden_members)
    end
  end
  # 贈ったいいね
  has_many(:informing_likes, :class_name => "Like", :foreign_key => :from_member_id, :primary_key => :id) do
    # 有効ないいねのみ取得する
    def valid_likes(current_user)
      where.not(:to_member_id => current_user.forbidden_members)
    end
  end

  # 自身をブロックしているユーザー
  has_many(:declined, :class_name => "Decline", :foreign_key => :to_member_id)
  # 自身がブロックしているユーザー
  has_many(:declining, :class_name => "Decline", :foreign_key => :from_member_id)
  # メンバーが公開中にしているアップロード画像
  has_many(:showable_images, lambda do
    where({
      :is_displayed => Constants::Binary::Type[:on],
      :is_deleted => Constants::Binary::Type[:off],
      :use_type => UtilitiesController::USE_TYPE_LIST[:profile],
    }).order(:created_at => :desc)
  end, **{
         :class_name => "Image",
         :foreign_key => :member_id,
       })

  # 自身に送信されたアクション一覧を取得
  has_many(:logs, :class_name => "Log", :foreign_key => :to_member_id, :primary_key => :id)
  # 自身が受け取ったtimelineのアクション
  has_many(:get_timelines, :class_name => "Timeline", :foreign_key => :to_member_id, :primary_key => :id)
  # 自身が送信したtimeline
  has_many(:send_timelines, :class_name => "Timeline", :foreign_key => :from_member_id, :primary_key => :id)
  # メンバーがアップロードした全画像
  # has_many :all_images,
  #          -> {
  #            self.order({
  #              :created_at => :desc,
  #              :updated_at => :desc,
  #            })
  #          }, **{ :class_name => "Image", :foreign_key => :member_id }

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

  # 興味のある言語一覧
  has_many :interested_languages, :class_name => "Language", :foreign_key => :member_id, :primary_key => :id
  # -----------------------------------------------------------------
  # ここまでリレーションの関連付け
  # -----------------------------------------------------------------

  # -----------------------------------------------------------------
  # いいねを贈ることができる異性のメンバー一覧を取得する
  # 第三引数の検索条件は任意
  # -----------------------------------------------------------------
  def self.hetero_members(current_user = nil, exculded_members = [], conditions = {})
    today = Time.now
    _year = today.strftime("%Y")
    _month = today.strftime("%m")
    _day = today.strftime("%d")
    _hour = today.strftime("%H")
    _minute = today.strftime("%M")
    _second = today.strftime("%S")

    # 検索条件のベース条件
    @members = self.left_joins(:interested_languages).where({
      :is_registered => Constants::Binary::Type[:on],
    }).and(
      self.where.not({
        :id => exculded_members,
      }).and(
        self.where.not({
          :id => current_user.id,
        })
      )
    )

    # 下限年齢
    if conditions[:from_age].nil? != true && conditions[:from_age].to_i > 0
      _year = _year.to_i - conditions[:from_age].to_i
      from_date = Time.local(
        _year,
        _month,
        _day,
        _hour,
        _minute,
        _second
      )
      @members = @members.where("birthday <= ?", from_date)
    end

    # 上限年齢
    if conditions[:to_age].nil? != true && conditions[:to_age].to_i > 0
      _year = _year.to_i - conditions[:to_age].to_i
      to_date = Time.local(
        _year,
        _month,
        _day,
        _hour,
        _minute,
        _second
      )
      @members = @members.where("birthday >= ?", to_date)
    end

    # 性別が設定されている場合
    if conditions[:gender].nil? != true && conditions[:gender].to_i > 0
      @members = @members.where({
        :gender => conditions[:gender],
      })
    end

    # 母国語が設定されている場合
    if conditions[:native_language].nil? != true && conditions[:native_language].to_i > 0
      @members = @members.merge(
        self.left_joins(:interested_languages).where({
          :native_language => conditions[:native_language],
        }).or(self.left_joins(:interested_languages).where({
          "languages.language" => conditions[:native_language],
        }))
      )
    end

    # 興味のある言語が指定されていた場合
    if conditions[:languages].nil? != true && conditions[:languages].length > 0
      @members = @members.where("languages.language" => conditions[:languages])
    end

    # 任意の名前が設定されている場合
    if conditions[:display_name].nil? != true && conditions[:display_name].length > 0
      @members = @members.where("display_name like ?", "%#{conditions[:display_name]}%")
        .or(@members.where("message like ?", "%#{conditions[:display_name]}%"))
    end
    return(@members)
  rescue => error
    logger.error(error)
    # 例外発生時は[nil]を返却
    return(nil)
  end

  # 指定したmember_idのユーザーをログイン中ユーザーが閲覧できる場合のみ
  # member情報を返却する
  def self.showable_member(current_user = nil, member_id = 0)
    _member = self.where({
      :is_registered => Constants::Binary::Type[:on],
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
    logger.error(error)
    return nil
  end

  # 利用規約への同意
  validates_each :agree do |object, attribute, data|
    if object.is_registered != Constants::Binary::Type[:on]
      if data == nil || (data.to_i != Constants::Binary::Type[:on])
        object.errors.add(attribute, "使用規約に同意する必要があります")
        next false
      end
      next true
    end
    next true
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
        object.errors.add(attribute, "仮登録がおこなわれていないようです")
      end
      next true
    end
  end

  # 性別は初期登録時から変更させない
  validates_each :gender do |object, attribute, data|
    # Get the member info while operating.
    # Except when executing seeder file.
    if (object.token == "from_seed")
      next true
    end
    member = Member.where({
      :token => object.token,
      :id => object.id,
    }).first()
    if member == nil
      object.errors.add(attribute, "仮登録アカウントが見つかりません")
      next false
    end

    if data.to_i != member.gender
      object.errors.add(attribute, "性別は変更できません")
      next false
    end
    # Exit successfully.
    next true
  end

  # 母国語の選択
  validates_each :native_language do |object, attribute, value|
    if value.to_i > Constants::Binary::Type[:off]
      # if value.to_i > UtilitiesController::BINARY_TYPE[:off]
      next true
    end
    object.errors.add(attribute, "母国語を選択して下さい")
    next false
  end

  # emailバリデーション
  validates :email, {
    :presence => {
      :message => "メールアドレスは必須項目です",
    },
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "メールアドレスはは1文字以上512文字以内で入力して下さい",
    },
  }

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

  # 母国語の設定
  validates :native_language, {
    :presence => {
      :message => "母国語を選択して下さい",
    },
    :inclusion => {
      :in => lambda do
        return Constants::Language::List.map do |lang|
                 next lang[:id]
               end
      end[],
    },
  }

  # validates :year, {
  #   :inclusion => {
  #     :in => lambda do
  #       p "################################################"
  #       year_list = UtilitiesController::YEAR_LIST.map do |year|
  #         next year[:id].to_s
  #       end

  #       p "################################################"
  #       pp year_list
  #     end[],
  #   },
  # }

  # validates :month, {
  #   :inclusion => {
  #     :in => lambda do
  #       return UtilitiesController::MONTH_LIST.map do |month|
  #                next month[:id]
  #              end
  #     end.call(),
  #   },
  # }

  # validates :day, {
  #   :inclusion => {
  #     :in => lambda do
  #       return UtilitiesController::DAY_LIST.map do |day|
  #                next day[:id]
  #              end
  #     end.call(),
  #   },
  # }

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
      logger.info "#{self.id}は#{member_id}にいいねをしています"
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
      logger.info "#{self.id}は#{member_id}にいいねされています"
      return true
    end
    return false
  end

  # -----------------------------------------------------
  # 指定したユーザーとマッチしているかどうか?
  # -----------------------------------------------------
  def match_you?(member_id)
    # Have you gotten likes from member_id?
    getting_likes = self.getting_likes.where({
      :from_member_id => member_id,
      :to_member_id => self.id,
    }).first()

    # Have you send like to member_id?
    informing_likes = self.informing_likes.where({
      :from_member_id => self.id,
      :to_member_id => member_id,
    }).first()

    if getting_likes != nil && informing_likes != nil
      return true
    else
      return false
    end
  end

  # -----------------------------------------------------------
  # 指定したユーザーにブロックされてないかしていないか?
  # You can browse member info which you selected, if return true on this method.
  # if return value is false, you cannot browse this member info.
  # -----------------------------------------------------------
  def browsable?(member_id)

    # Does login user decline selected member?
    browsable = self.declined.where({
      :from_member_id => member_id,
    }).first()
    if browsable != nil
      return false
    end

    # Is login user  declined by selected member?
    browsable = self.declining.where({
      :to_member_id => member_id,
    }).first()

    if browsable != nil
      return false
    end

    return true
  end

  # # 自身が贈った現時点で有効なlike
  # def informing_valid_likes
  #   valid_likes = Array.new()
  #   likes = self.informing_likes.map do |like|
  #     next like.to_member_id
  #   end
  #   valid_likes = likes - self.forbidden_members
  #   return valid_likes
  # end

  # # 自身がもらった現時点で有効なlike
  # def getting_valid_likes
  #   valid_likes = Array.new()
  #   likes = self.getting_likes.map do |like|
  #     next like.from_member_id
  #   end
  #   valid_likes = likes - self.forbidden_members
  #   return valid_likes
  # end

  # アクセスできないメンバー一覧
  def forbidden_members
    # アクセス禁止対象メンバー
    forbidden_members = Array.new()

    # ブロックしているユーザー
    declining = self.declining.map do |d|
      next d.to_member_id
    end

    # ブロックされているユーザー
    declined = self.declined.map do |d|
      next d.from_member_id
    end
    # アクセス不可メンバー
    forbidden_members = declined + declining
  end

  def native_language_string
    @native_language_string = ""
    # attributeを取得しない場合
    if self.respond_to?(:native_language) != true
      return nil
    end
    Constants::Language::List.each do |lang|
      if self.native_language == lang[:id]
        @native_language_string = lang[:value]
        next
      end
    end
    return @native_language_string
  end

  # 興味のある言語一覧を返却する
  def interested_languages_string
    languages = []
    self.interested_languages.each do |lang|
      Constants::Language::List.each do |l|
        if l[:id] == lang.language
          languages.push(l[:value])
        end
      end
    end
    return languages
  end

  def year
    if self.birthday != nil
      return self.birthday.strftime("%Y")
    end
  end

  def month
    if (self.birthday != nil)
      return self.birthday.strftime("%-m")
    end
  end

  def day
    if (self.birthday != nil)
      return self.birthday.strftime("%-d")
    end
  end

  # 現時点の年齢を取得する
  def age
    if (self.birthday != nil)
      return (Time.new.strftime("%Y%m%d").to_i - self.birthday.strftime("%Y%m%d").to_i) / 10000
    end
    return "?"
  end

  def matching_members(member_id, forbidden_members = [])
    # Fetch likes which logged in user send.
    informing_likes = Like.select(:to_member_id).where({
      :from_member_id => member_id,
    }).to_a.map do |like|
      next like.to_member_id.to_i
    end

    # ログインユーザーがいいねしたメンバーが自身をいいねしているかどうか
    getting_likes = Like.select(:from_member_id).where({
      :to_member_id => member_id,
    }).to_a.map do |like|
      next like.from_member_id.to_i
    end

    # 双方いいねしている場合かつ､ブロックしてない且つされていないメンバーを取得
    matching_members = getting_likes & informing_likes
    matching_members = Member.where({
      :id => matching_members,
    }).and(
      Member.where.not({
        :id => forbidden_members,
      })
    )
    return (matching_members)
  end
end
