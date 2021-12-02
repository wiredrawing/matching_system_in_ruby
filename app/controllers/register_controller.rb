class RegisterController < ApplicationController
  before_action :set_register, only: %i[ show edit update destroy ]
  before_action :set_member, only: %i[ main_create ]

  def index
    @register = Register.new
    render ({
      :template => "register/index",
    })
  end

  # -----------------------------------------
  # 仮登録処理の実行
  # -----------------------------------------
  def create
    # 本登録用トークンを生成
    token = TokenForApi.make_random_token(128)
    logger.debug "新規で生成されたトークン #{token}"

    # 重複仮登録の場合を検証
    @register = Register.find_by({
      :email => register_params[:email],
      :is_registered => UtilitiesController::BINARY_TYPE[:off],
    })

    update_params = register_params.to_hash
    update_params["token"] = token

    completed = false
    if @register != nil
      response = @register.update(update_params)
      completed = true
    else
      @register = Register.new(update_params)
      if @register.validate && @register.save!
        completed = true
      end
    end

    if completed == true
      return render :template => "register/completed"
    end
    # エラー時
    return render ({ :template => "register/index" })
  rescue => exception
    logger.debug exception
    return render :template => "errors/index"
  end

  # -----------------------------------------
  # 本登録処理初期表示
  # -----------------------------------------
  def main_index
    # 仮登録ユーザーの存在チェック
    @member = Member.find_by({
      :id => params[:id],
      :token => params[:token],
      :is_registered => UtilitiesController::BINARY_TYPE[:off],
    })

    # 仮登録中ユーザーが存在する場合
    if @member != nil
      return render ({ :template => "register/main_index" })
    else
      return render :template => "register/error"
    end
  rescue => error
    logger.debug error
    return render :template => "errors/index"
  end

  # -----------------------------------------
  # 本登録処実行処理
  # -----------------------------------------
  def main_create
    # memberオブジェクトの作成
    @member = Member.new(member_params)
    if @member.validate() != true
      raise ActiveModel::ValidationError.new @member
    end

    # memberオブジェクトの再取得
    @member = Member.find_by({
      :id => member_params[:id],
      :token => member_params[:token],
      :is_registered => UtilitiesController::BINARY_TYPE[:off],
    })
    if (@member == nil)
      raise StandardError.new("仮登録中ユーザーが見つかりませんでした")
    end

    # postデータをHashオブジェクトに
    member_params_hash = member_params.to_hash()
    member_params_hash["is_registered"] = Constants::Binary::Type[:on]
    member_params_hash["token_for_api"] = TokenForApi::make_random_token(128)

    # updateメソッドが成功した場合
    if @member.update(member_params_hash) != true
      raise StandardError.new("本登録処理に失敗しました")
    end

    # ログインページにリダイレクト
    return(redirect_to(login_url))
  rescue ActiveModel::ValidationError => error
    # モデル内Errorの取得
    logger.debug error.model.errors.messages
    return render({ :template => "register/main_index" })
  rescue => exception
    logger.debug exception
    return render({ :template => "register/main_index" })
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
        :token,
        :native_language,
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
        :token,
        :native_language,
        :agree,
      )
  end
end
