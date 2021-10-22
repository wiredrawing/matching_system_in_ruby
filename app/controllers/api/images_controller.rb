class Api::ImagesController < ApplicationController
  # before_action :set_enabled_image, :only => %i[show_owner edit update destroy]

  ###############################################
  # ログインユーザーが自身の画像を参照する
  ###############################################
  def show_owner
    begin
      puts("show_owner --------------------------->")
      target_image = {
        :id => params[:id],
        :member_id => @current_user.id,
      }
      @image = Image.find_by(target_image)

      if @image == nil
        # 画像が有効でない場合は例外raise
        raise StandardError.new "有効な画像が見つかりません in show_owner"
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

  # 自身以外のmemberの画像を閲覧
  def show
    begin
      puts("show --------------------------->")
      target_image = {
        :id => params[:id],
        :member_id => params[:member_id],
        :is_displayed => UtilitiesController::BINARY_TYPE[:on],
        :is_deleted => UtilitiesController::BINARY_TYPE[:off],
      }
      @image = Image.find_by(target_image)

      if @image == nil
        # 画像が有効でない場合は例外raise
        raise StandardError.new "有効な画像が見つかりません in show"
      end

      file_path = @image.fetch_file_path

      # imagemagickで読み込み
      image = Magick::ImageList.new(file_path)
      # ぼかし設定がonの場合
      if (@image.blur_level > 0)
        p(@image.blur_level)
        image = image.blur_image(10, @image.blur_level)
        p("Magick::ImageList.new(file_path)")
      end
      # p(image.to_blob)
      # 画像出力
      render({
        # 生のコンテンツを出力する場合
        :body => image.to_blob,
        :content_type => @image.extension,
      })
    rescue => exception
      ###############################################
      # http 404 bad requestを表示
      ###############################################
      # p("exception.methods----------------->", exception.methods)
      # p(exception.message)
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
end
