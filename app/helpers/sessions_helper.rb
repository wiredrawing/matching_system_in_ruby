module SessionsHelper
  def login(member)
    # セッションにmember_idを保存
    session[:member_id] = member.id

    self.current_user()
  end

  def current_user
    if @current_user.nil?
      @current_user = Member.includes(
        :getting_likes,
        :informing_likes,
        :declined,
        :declining,
        :interested_languages
      ).find_by(id: session[:member_id])
    else
      return @current_user
    end
  end

  def logged_in?
    if self.current_user.nil?
      return false
    end
    return true
  end
end
