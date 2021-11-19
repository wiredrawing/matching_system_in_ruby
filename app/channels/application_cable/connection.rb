module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      p ("a■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■")
      self.current_user = find_verified_user
      p self.current_user
      p ("i■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■")
    end

    protected

    def find_verified_user
      p "○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○"
      pp cookies
      pp request
      pp request.session
      pp session
      p "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      if current_user = Member.find_by(id: cookies.signed[:member_id])
        current_user
      else
        reject_unauthorized_connection
      end
    rescue => error
      p error.message
    end
  end
end
