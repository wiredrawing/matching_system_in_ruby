class NoticesController < ApplicationController

  # 通知ページTOP
  def index
    @log_ids = Log.select([
      "max(id) as id",
    ]).includes([
      :from_member,
      :to_member,
    ]).where({
      :to_member_id => @current_user.id,
    }).group([
      :from_member_id,
      :to_member_id,
      :action_id,
    ])

    @logs = Log.includes([
      :from_member,
      :to_member,
    ]).where({
      :id => @log_ids,
    }).order(:created_at => :desc)

    response = @uncheck_notices.update({
      :is_browsed => UtilitiesController::BINARY_TYPE[:on],
    })

    pp @logs

    return render :template => "notices/index"
  rescue => error
    logger.debug error.backtrace
    return render :template => "errors/index"
  end
end
