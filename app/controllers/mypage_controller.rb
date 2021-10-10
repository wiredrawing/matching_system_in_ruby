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
end
