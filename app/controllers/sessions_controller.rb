class SessionsController < ApplicationController
  def new
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
      :is_registered => UtilitiesController::BINARY_TYPE[:on],
    })

    if @login.validate() != true
      raise StandardError.new "メンバー情報が見つかりませんでした"
    end
    # Forge new member object again, if vaildation to login is successfully.
    @member = Member.find_by({
      :email => params[:login][:email],
      :is_registered => UtilitiesController::BINARY_TYPE[:on],
    })
    # validation check.
    if @member == nil
      raise StandardError.new "メンバー情報が見つかりませんでした"
    end

    # Reforge the token to request for api, and update record of login user's info.
    new_token = TokenForApi.make_random_token(128)
    response = @member.update({
      :token_for_api => new_token,
    })
    if response != true
      raise StandardError.new "ログインに失敗しました"
    end

    # Execute logging in.
    self.login(@member)
    return redirect_to(mypage_url)
  rescue => exception
    # When failed logging in.
    render :template => "sessions/new"
  end

  # ログインページはログイン状態が不要なためoverride
  def login_check
    print("必ず実行される処理 ==========> login_check")
    p(self.logged_in?)
    if (self.logged_in? == true)
      print("既にログイン中の場合はリダイレクトさせる")
      return(redirect_to(mypage_url))
    end
  end
end
