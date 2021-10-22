class TopController < ApplicationController
  def index

    # ログインチェック
    if self.logged_in? == true
      # マイページへ
      return redirect_to(mypage_url)

      # あるいはTOPコンテンツ?
      # 人気のメンバー
      render({ :template => "top/index" })
    end

    # 未ログイン時
    return redirect_to(login_url)
  end
end
