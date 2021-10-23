class Member < ApplicationRecord
  # リレーションの関連付け
  # もらったいいいね
  has_many(:getting_likes, :class_name => "Like", :foreign_key => :to_member_id)
  # 贈ったいいね
  has_many(:informing_likes, :class_name => "Like", :foreign_key => :from_member_id)
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
    })
  end
  has_many(:all_images, _anonymous, **{
                                      :class_name => "Image",
                                      :foreign_key => :member_id,
                                    })

  # いいねを贈ることができる異性のメンバー一覧を取得する
  def self.hetero_members(current_user = nil, exculded_members = [])
    print("ログインユーザーとは性別のことなるメンバー一覧を取得する")
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
      print("Happen error------------------>")
      puts(error)
      # 例外発生時は[nil]を返却
      return(nil)
    end
  end

  # 指定したmember_idのユーザーをログイン中ユーザーが閲覧できる場合のみ
  # member情報を返却する
  def self.showable_member(current_user = nil, member_id = 0)
    begin
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
      print(_member.class)
      print("_member.first =========>", _member, ">>>")
      print("_member == nil", _member == nil, ">>>")
      if _member == nil
        raise StandardError.new("指定したユーザーが見つかりませんでした")
      end
      return(_member)
    rescue => error
      print("error ----------->", error)
    end
  end

  # 特定のキーに対して､任意のバリデー処理を実行させる
  validates_each(:token) do |object, attr, data|
    if (object.token == "from_seed")
      next true
    else
      _member = Member.where({
        :token => data,
        :id => object.id,
      }).first

      if (_member == nil)
        object.errors.add(attr, "仮登録トークンが不正です")
      end
      next true
    end
  end

  # emailバリデーション
  validates(:email, {
    :presence => true,
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "メールアドレスはは1文字以上512文字以内で入力して下さい",
    },
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
  validates(:gender, {
    :presence => true,
    :length => {
      :minimum => 0,
    },
    :inclusion => {
      # mapメソッドで1以上の値で構成された配列を返却する
      :in => (lambda do
        gender_id_list = []
        UtilitiesController::GENDER_LIST.map do |gender|
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
  })

  validates :given_name, {
    :presence => true,
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "名前は1文字以上512文字以内で入力して下さい",
    },
  }

  validates :family_name, {
    :presence => true,
    :length => {
      :minimum => 1,
      :maximum => 512,
      :message => "名字は1文字以上512文字以内で入力して下さい",
    },
  }

  # パスワード
  validates(:password, {
    :presence => true,
    :length => {
      :minimum => 10,
      :maximun => 64,
    },
    :on => :member_update_password,
  })

  # パスワード確認用
  validates (:password_confirmation), ({
    :presence => true,
    :length => {
      :minimum => 10,
      :maximun => 64,
    },
    :on => :member_update_password,
  })

  has_secure_password

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
    likes = Like.where({
      :from_member_id => member_id,
      :to_member_id => self.id,
    }).or(
      Like.where({
        :from_member_id => self.id,
        :to_member_id => member_id,
      })
    )

    if (likes.length == 2)
      return true
    else
      return false
    end
  end

  # 指定したユーザにおすすめのメンバー一覧を取得する
  def recommended_members()
  end
end
