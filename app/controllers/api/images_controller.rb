class Api::ImagesController < ApplicationController
  before_action :set_enabled_image, :only => %i[show_owner edit update destroy]

  ###############################################
  # 画像表示
  ###############################################
  def show_owner
    puts("=====================================")
    p(@image)
    begin
      if @image == nil
        # 画像が有効でない場合は例外raise
        raise StandardError.new "有効な画像が見つかりません"
      end

      file_path = @image.fetch_file_path
      # 画像出力
      render({
        :file => file_path,
        :content_type => @image.extension,
      })
    rescue => exception
      ###############################################
      # http 404 bad requestを表示
      ###############################################
      p("exception.methods----------------->", exception.methods)
      render ({
        :json => {
          :error => exception.message,
        },
        :content_type => "application/json",
        :status => 404,
      })
    end
  end

  private

  ###############################################
  # 指定したimage.is_displayed == 1なら画像表示
  # URLパラメータから@imageオブジェクトを事前設定する
  ###############################################
  def set_enabled_image
    # 指定した画像がログインユーザーのものであれば表示
    p("params ==========================>", params)
    p("params[:id] ==========================>", params[:id])
    p(@current_user.id)
    @image = Image.find_by ({
      :id => params[:id],
      :member_id => @current_user.id,
    })
    return @image
  end
end
