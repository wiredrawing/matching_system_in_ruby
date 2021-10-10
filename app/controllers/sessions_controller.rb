class SessionsController < ApplicationController
  def new
    render ({
      :template => "sessions/new",
    })
  end

  def create
    p "params[:session]", params[:session]

    member = Member.find_by({
      :email => params[:session][:email],
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
end
