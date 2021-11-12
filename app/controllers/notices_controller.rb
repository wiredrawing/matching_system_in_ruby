class NoticesController < ApplicationController

  # 通知ページTOP
  def index
    @logs = Log.includes([
      :from_member,
      :to_member,
    ]).where({
      :to_member_id => @current_user.id,
    })

    return render :template => "notices/index"
  end
end
