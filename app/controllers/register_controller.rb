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
    # 仮登録では､メールアドレスとニックネームのみ登録する
    # 仮登録用のトークンを生成
    _register_params = register_params.to_h
    _register_params[:token] = make_random_token

    @register = Register.new(_register_params)

    # validation成功時は､そのまま新規insert後完了ページを表示
    if @register.validate && @register.save
      p ("@register.save()の実行結果 ===>"), (response)
      return render :template => "register/completed"
    end

    # vaildationエラーを画面表示
    p @register.errors.messages
    return render ({ :template => "register/index" })
  end

  # 本登録処理
  def main_index
    # 仮登録ユーザーの存在チェック
    # idとtokenがマッチする場合のみ
    if Register.exists? params.permit(:id, :token)
      @member = Register.find_by params.permit :id, :token
      return render ({ :template => "register/main_index" })
    else
      template = { :template => "register/error" }
      return render template
    end
  end

  def main_create
    # idとパスワードのみを使ってレコードの存在チェック
    p "Register.exists?({ :id => params[:id], :token => params[:token] })", Register.exists?({ :id => params[:id], :token => params[:token] })
    if Register.exists?({ :id => params[:id], :token => params[:token] })

      # 更新処理の可否で制御
      response = @member.update(member_params)
      if response
        redirect_to new_member_url
      else
        render({ :template => "register/main_index" })
      end
    end
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
        :email,
        :display_name,
        :gender
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
        :password,
        :password_confirmation,
        :password_digest,
        :token
      )
  end
end
