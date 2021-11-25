class LoadEagerModel
  def initialize(app)
    @app = app
  end

  def call(env)

    # 登録済みメンバー情報を取得
    @registered_members = Member.where({
      :is_registered => UtilitiesController::BINARY_TYPE[:on],
    }).map do |member|
      next member.id
    end
    env["registered_members"] = @registered_members

    return @app.call(env)
  end
end
