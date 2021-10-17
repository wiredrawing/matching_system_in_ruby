class ApplicationController < ActionController::Base
  # helperの読み込み
  include SessionsHelper
  include RegisterHelper
  include MembersHelper
  include Api::ImagesHelper
  before_action :set_gender_list
  before_action :login_check

  private

  ###########################################
  # 未ログインの場合は､ログインページへリダイレクト
  ###########################################
  def login_check
    # sessions_helperのメソッドを読み込む
    if self.logged_in? == true
      return true
    end
    # 未ログイン時は､ログインフォームへ
    return(redirect_to(login_url))
  end
end
