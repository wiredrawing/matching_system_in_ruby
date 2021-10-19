class SessionsController < ApplicationController
  def new
    render ({
      :template => "sessions/new",
    })
  end

  def create
    p "params[:session]", params[:session]

    p "UtilitiesController.BINARY_TYPE", UtilitiesController::BINARY_TYPE
    member = Member.find_by({
      :email => params[:session][:email],
      :is_registered => UtilitiesController::BINARY_TYPE[:on],
    })

    p "member ====>", member
    if member && member.authenticate(params[:session][:password])
      # ログイン処理を実行
      self.login(member)
      p "mypage_url => #{mypage_url}"
      redirect_to(mypage_url)
    else
      render ({
        :template => "sessions/new",
      })
    end
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
