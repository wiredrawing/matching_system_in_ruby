class SessionsController < ApplicationController
  def new
    @login = Login.new()
    render ({
      :template => "sessions/new",
    })
  end

  def create
    # 新規モデルを作成
    params.fetch(:login, {}).permit(
      :email,
      :password,
    )
    @login = Login.new({
      :email => params[:login][:email],
      :password => params[:login][:password],
      :is_registered => UtilitiesController::BINARY_TYPE[:on],
    })

    if @login.validate() == true

      # バリデーションが成功した場合､改めてmemberオブジェクトを生成する
      @member = Member.find_by({
        :email => params[:login][:email],
        :is_registered => UtilitiesController::BINARY_TYPE[:on],
      })

      # ログイン処理を実行
      self.login(@member)
      return redirect_to(mypage_url)
    end
    print("======================================")
    p(@login.errors)
    p(@login.errors.any?)
    p(@login.errors[:email])
    p(@login.errors[:password])
    @login.errors.each do |error|
      p(error.full_message)
    end
    # ログイン認証失敗時
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
