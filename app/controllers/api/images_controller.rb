class Api::ImagesController < ApplicationController
  before_action :set_enabled_image, :only => %i[show edit update destroy]

  ###############################################
  # 画像表示
  ###############################################
  def show
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
    p("params ==========================>", params)
    p("params[:id] ==========================>", params[:id])
    @image = Image.find_by ({
      :id => params[:id],
      :is_displayed => 1,
    })
  end
end
