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

    if member && member.authenticate(params[:session][:password])

      # ログイン処理を実行
      login(member)
    else
    end

    render ({
      :template => "sessions/new",
    })
  end
end
