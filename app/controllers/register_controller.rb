class RegisterController < ApplicationController
  before_action :set_register, only: %i[ show edit update destroy ]
  before_action :set_member, only: %i[ main_create ]

  def index
    @register = Register.new
    render ({
      :template => "register/index",
    })
  end

  ###########################################
  # 仮登録処理の実行
  ###########################################
  def create
    # 本登録用トークンを生成
    _token = self.make_random_token (64)
    print("生成された64文字のトークン ----->", _token)
    # 重複仮登録の場合を検証
    @register = Register.find_by ({
      :email => register_params[:email],
      :is_registered => UtilitiesController::BINARY_TYPE[:off],
    })

    update_params = register_params.to_hash
    update_params["token"] = _token
    # メールアドレスを小文字する
    update_params["email"] = update_params["email"].downcase

    _completed = false
    if @register != nil
      _response = @register.update(update_params)
      _completed = true
    else
      @register = Register.new(update_params)
      if @register.validate && @register.save
        _completed = true
      end
    end

    if _completed == true
      return render :template => "register/completed"
    else
      return render ({ :template => "register/index" })
    end
  end

  ###########################################
  # 本登録処理初期表示
  ###########################################
  def main_index
    # 仮登録ユーザーの存在チェック
    _existed = Register.exists?({
      :id => params[:id],
      :token => params[:token],
      :is_registered => UtilitiesController::BINARY_TYPE[:off],
    })

    # 仮登録中ユーザーが存在する場合
    if _existed == true

      # memberモデル経由で取得する
      @member = Member.find_by({
        :id => params[:id],
        :token => params[:token],
        :is_registered => UtilitiesController::BINARY_TYPE[:off],
      })
      # @register = Register.find_by(params.permit(:id, :token))
      # print("@register=====> ", @register)
      # print("@register=====> ", @register.errors)
      return render({ :template => "register/main_index", :aa => :aa })
    else
      _template = { :template => "register/error" }
      return(render(_template))
    end
  end

  ###########################################
  # 本登録処実行処理
  ###########################################
  def main_create
    # 例外ハンドリング
    begin
      puts("----------------------------------------------------")
      # memberオブジェクトの作成
      @member = Member.new(member_params)
      _valid = @member.validate()

      if _valid != true
        raise StandardError.new("バリデーションエラーが発生しています")
      end

      # memberオブジェクトの再取得
      @member = Member.find_by({
        :id => member_params[:id],
        :token => member_params[:token],
      # :is_registered => UtilitiesController::BINARY_TYPE[:off],
      })
      if (@member == nil)
        raise StandardError.new("仮登録中ユーザーが見つかりませんでした")
      end

      print("is_exists ====>", @member)
      # postデータをHashオブジェクトに
      member_params_hash = member_params.to_hash()
      member_params_hash["is_registered"] = UtilitiesController::BINARY_TYPE[:on]
      print("member_params_hash-------------->")
      p(member_params_hash)
      _updated = @member.update(member_params_hash)

      # updateメソッドが成功した場合
      if _updated != true
        raise StandardError.new("本登録処理に失敗しました")
      end

      # ログインページにリダイレクト
      return(redirect_to(login_url))
    rescue => exception
      # 例外発生時!
      # puts("@register ------>", @register)
      # puts("@register.email ------>", @register.email)
      puts("exception.message ---->", exception.message)
      # puts("exception.line ------->", exception.line)
      render({ :template => "register/main_index" })
    end
  end

  # ログインチェックをoverride
  def login_check
    return true
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_register
    @register = Register.find(params[:id])
  end

  def set_member
    @member = Member.find(params[:id])
  end

  def register_params
    params.fetch(:register, {})
      .permit(
        :id,
        :email,
        :display_name,
        :family_name,
        :given_name,
        :gender,
        :height,
        :weight,
        :birthday,
        :salary,
        :message,
        :memo,
        :is_registered,
        :password,
        :password_confirmation,
        :password_digest,
        :token
      )
  end

  def member_params
    params.fetch(:member, {})
      .permit(
        :id,
        :email,
        :display_name,
        :family_name,
        :given_name,
        :gender,
        :height,
        :weight,
        :birthday,
        :salary,
        :message,
        :memo,
        :is_registered,
        :password,
        :password_confirmation,
        :password_digest,
        :token
      )
  end
end
