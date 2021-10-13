class ApplicationController < ActionController::Base
  # helperの読み込み
  include SessionsHelper
  include RegisterHelper
  include MembersHelper
  before_action :set_gender_list
  # before_action :logged_in?
  before_action :login_check

  private

  def login_check
    # sessions_helperのメソッドを読み込む
    p "[self.login_check] --------->", self.logged_in?
    return redirect_to signin_url
  end
end
