class MypageController < ApplicationController
  before_action :login_check

  def index
    return render({ :template => "mypage/index" })
  end

  def edit
    p "MypageController#edit =="
    return render({ :template => "mypage/edit" })
  end

  # ログインユーザーの情報更新処理
  def update
    local_func = lambda do |param|
      # parma => 自由変数
      inner_func = lambda do |inner_param|
        param += inner_param
        return param
      end
      return inner_func
    end[3]

    p "update ----->"
    p ("self.params"), (self.params)
    p ("self.member_params"), (self.member_params)
    _member = Member.find(self.member_params[:id])
    p ("_member"), (_member)
    _response = _member.update({
      :id => member_params[:id],
      :email => member_params[:email],
    # :display_name => member_params[:display_name],
    # :family_name => member_params[:family_name],
    # :given_name => member_params[:given_name],
    # :gender => member_params[:gender],
    # :height => member_params[:height],
    # :weight => member_params[:weight],
    # :birthday => member_params[:birthday],
    # :salary => member_params[:salary],
    # :message => member_params[:member],
    # :memo => member_params[:memo],
    })
    p ("_response"), _response
    p _member.errors.messages
    return render({ :template => "mypage/edit" })
  end

  private

  ##########################################
  # マイページへはログイン済みユーザーのみ許可
  ##########################################
  def login_check
    p "======================================================"
    p "MypageController#login_check"
    p "self.logged_in?=======>", self.logged_in?
    p "self.current_user ====>", self.current_user
    p "======================================================"
    if self.logged_in? != true
      return redirect_to(signin_url)
    end

    p "@current_user ===>", @current_user
  end

  def member_params
    params.fetch(:member, {}).permit(
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
      :password_digest
    )
  end
end
