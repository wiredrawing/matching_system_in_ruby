module SessionsHelper
  def login(member)
    puts "================================================="
    p "SessionHelper#login を実行中"
    puts "================================================="
    session[:member_id] = member.id
  end

  def current_user
    puts "================================================="
    p "SessionHelper#current_user を実行中"
    puts "================================================="

    if (defined?(@current_user))
      return @current_user
    else
      @current_user = Member.find_by(id: session[:member_id])
      return @current_user
    end
  end

  def logged_in?
    if defined?(@current_user)
      return true
    else
      return false
    end
  end
end
