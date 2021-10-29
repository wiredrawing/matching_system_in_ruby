class LoadEagerModel
  def initialize(app)
    @app = app
  end

  def call(env)
    res = @app.call(env)
    return res
  end
end
