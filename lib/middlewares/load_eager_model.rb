class LoadEagerModel
  def initialize(app)
    p("initialize")
    @app = app
    p(app)
    p("end")
  end

  def call(env)
    if env["REQUEST_METHOD"] == "POST"
      puts("POSTメソッドでアクセス中です")
    else
      puts("POSTメソッド以外でアクセス中")
    end

    if env["HTTP_TOKEN_FOR_API"] != nil
      puts("APIリクエスト用トークン -->")
      puts(env["HTTP_TOKEN_FOR_API"])
    end

    pp env.keys
    p env["action_dispatch.routes"].class
    pp env["action_dispatch.routes"].url_helpers
    # p("===========================================")
    # p env.class
    # env.each do |key, value|
    #   puts key
    #   puts value
    #   puts "---------------------------------------"
    # end
    # puts("任意のheader =====>")
    # pp(env["HTTP_TOKEN_FOR_API"])

    # puts("REQUEST_METHOD =====>")
    # pp(env["REQUEST_METHOD"])

    # puts("POST_DATA =====>")
    # pp(env["rack.request.form_hash"]["add_params"] = "追加のpostパラメータ")
    # pp env["rack.request.form_hash"]
    # puts("Routes =====>")
    # pp(env["action_dispatch.routes"].to_s)

    # pp(env.methods)
    # pp(@app.methods)
    # pp(@app.routes)
    # pp(request.class)
    res = @app.call(env)
    # pp(res)
    p("0000000000000000000000000000000000000000000000")
    return res
  end
end
