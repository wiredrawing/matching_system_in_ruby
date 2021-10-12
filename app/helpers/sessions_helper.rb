module SessionsHelper
  def login(member)
    puts "================================================="
    p "SessionHelper#login を実行中"
    p member
    puts "================================================="
    # セッションにmember_idを保存
    session[:member_id] = member.id

    self.current_user()
  end

  def current_user
    if @current_user.nil?
      @current_user = Member.find_by(id: session[:member_id])
    else
      return @current_user
    end
  end

  def logged_in?
    if self.current_user.nil?
      puts "[NG]ログインしていません｡"
      return false
    end
    puts "[OK]ログイン中です｡"
    return true
  end
end
