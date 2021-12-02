class SessionsController < ApplicationController
  def new
    # pp "########################################"
    # p "ミドルウェアで設定した内容"
    # pp request.env["registered_members"]
    # p "ミドルウェアで設定した内容"
    @login = Login.new()
    render(
      :template => "sessions/new",
    )
  end

  def create
    params.fetch(:login, {}).permit(
      :email,
      :password,
    )
    @login = Login.new({
      :email => params[:login][:email],
      :password => params[:login][:password],
      :is_registered => Constants::Binary::Type[:on],
    })

    if @login.validate() != true
      raise StandardError.new "メンバー情報が見つかりませんでした"
    end

    # Forge new member object again, if vaildation to login is successfully.
    @member = Member.find_by({
      :email => params[:login][:email],
      :is_registered => Constants::Binary::Type[:on],
    })

    # validation check.
    if @member == nil
      raise StandardError.new "メンバー情報が見つかりませんでした"
    end

    # Reforge the token to request for api, and update record of login user's info.
    new_token = TokenForApi.make_random_token(128)
    p new_token

    response = @member.update({
      :token_for_api => new_token,
    })
    p response
    pp @member
    p new_token
    if response != true
      p "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      p response
      raise StandardError.new "ログインに失敗しました"
    end

    # Execute logging in.
    self.login(@member)
    return redirect_to(mypage_url)
  rescue => error
    p error
    # When failed logging in.
    render :template => "sessions/new"
  end

  # ログインページはログイン状態が不要なためoverride
  def login_check
    if (self.logged_in? == true)
      return(redirect_to(mypage_url))
    end
  end
end
