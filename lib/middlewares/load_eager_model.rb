class LoadEagerModel
  def initialize(app)
    @app = app
  end

  def call(env)
    p("ここからミドルウェアの実行---------------------------------------")
    res = @app.call(env)
    p("ここまでミドルウェアの実行---------------------------------------")
  end
end
