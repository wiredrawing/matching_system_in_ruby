class RegisterController < ApplicationController
  before_action :set_register, only: %i[ show edit update destroy ]
  before_action :set_member, only: %i[ main_create ]

  def index
    @register = Register.new
    @genders = [
      ["未設定", 0],
      ["男性", 1],
      ["女性", 2],
    ]
    render ({
      :template => "register/index",
    })
  end

  def create
    # 仮登録では､メールアドレスとニックネームのみ登録する
    @genders = [
      ["未設定", 0],
      ["男性", 1],
      ["女性", 2],
    ]
    # 仮登録用のトークンを生成
    _register_params = register_params.to_h
    _register_params[:token] = make_random_token

    @register = Register.new(_register_params)
    if @register.save == true
      render :template => "register/completed"
    else
      render ({ :template => "register/index" })
    end
  end

  # 本登録処理
  def main_index
    id = params[:id]
    token = params[:token]
    # idとtokenがマッチする場合のみ
    @member = Member.find_by({
      :id => id,
      :token => token,
    })
    @genders = [
      ["未設定", 0],
      ["男性", 1],
      ["女性", 2],
    ]
    render ({ :template => "register/main_index" })
  end

  def main_create
    @genders = [
      ["未設定", 0],
      ["男性", 1],
      ["女性", 2],
    ]
    # idとパスワードのみを使ってレコードの存在チェック
    if Register.exists?({ :id => params[:id], :token => params[:token] })

      # 更新処理の可否で制御
      response = @member.update(member_params)
      if response
        redirect_to new_member_url
      else
        render ({ :template => "register/main_index" })
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
