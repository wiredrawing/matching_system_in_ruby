require "digest"

class Api::ImagesController < ApplicationController

  # csrfを除外するmethod
  protect_from_forgery :except => [
    :upload,
    :update,
    :delete,
    :owner_images,
    :owner_image_url,
    :image_url,
  ]

  # Get all images that user who has logged in has.
  # /api/image/list/:id/:token_for_api
  # Set token with key named 'token-for-api' to authenticate on the headers.
  def list
    @member_id = request.headers["member-id"].to_i
    @token_for_api = request.headers["token-for-api"]
    @token_check = TokenCheck.new({
      :id => @member_id,
      :token_for_api => @token_for_api,
    })
    # Check the validation.
    if @token_check.validate() != true
      raise StandardError.new "認証エラー"
    end

    # 対象の画像一覧を取得する
    @images = Image.includes(:member, :member_blongs_to).where({
      :member_id => @member_id,
    }).order(:created_at => :desc)

    return render :json => @images.to_json(:include => [
                                             :member,
                                             :member_blongs_to,
                                           ])
  rescue => exception
    puts("[例外発生--------------------------------------------]")
    pp(exception)
    logger.error "#{exception.message}"
    return render :json => @token_check.errors.messages
  end

  # Return images list which other member has.
  def member
    # Check the authentication user who requested other member's images to watch.
    @member_id = request.headers["member-id"].to_i
    @token_for_api = request.headers["token-for-api"]
    @token_check = TokenCheck.new({
      :id => @member_id,
      :token_for_api => @token_for_api,
    })
    # Check the validation.
    if @token_check.validate() != true
      raise StandardError.new "認証エラー"
    end

    # 対象の画像一覧を取得する
    @images = Image.where({
      :member_id => params[:member_id].to_i,
      :is_displayed => UtilitiesController::BINARY_TYPE[:on],
      :is_deleted => UtilitiesController::BINARY_TYPE[:off],
    }).order(:created_at => :desc)

    return render :json => @images.to_json
  rescue => exception
    p(exception)
    logger.debug "#{exception.message}"
    return render :json => @token_check.errors.messages
  end

  # Show the images published by owner.
  def image_url
    @image = Image.find_by({
      :id => params[:id],
      :token => params[:token],
      :is_displayed => UtilitiesController::BINARY_TYPE[:on],
      :is_deleted => UtilitiesController::BINARY_TYPE[:off],
    })
    if @image == nil
      raise StandardError.new @errors.push("画像がみつかりません")
    end
    return render :file => @image.fetch_file_path, :content_type => @image.extension, :status => 200
  rescue => exception
    return render :json => exception.message
  end

  # Show the image owner who has.
  def owner_image_url
    @errors = Array.new
    # オーナーの認証
    @token_check = TokenCheck.new({
      :id => params[:member_id].to_i,
      :token_for_api => params[:token_for_api],
    })
    if @token_check.validate() != true
      raise StandardError.new "ユーザー認証に失敗しました"
    end
    @image = Image.find_by({
      :id => params[:id],
      :member_id => params[:member_id],
    })
    if @image == nil
      raise StandardError.new @errors.push("画像がみつかりません")
    end
    return render :file => @image.fetch_file_path, :content_type => @image.extension, :status => 200
  rescue => exception
    return render :json => exception.message
  end

  # def show_owner
  #   begin
  #     target_image = {
  #       :id => params[:id],
  #       :member_id => @current_user.id,
  #     }
  #     @image = Image.find_by(target_image)

  #     if @image == nil
  #       # 画像が有効でない場合は例外raise
  #       raise StandardError.new "有効な画像が見つかりません in show_owner"
  #     end

  #     file_path = @image.fetch_file_path
  #     # 画像出力
  #     render({
  #       :file => file_path,
  #       :content_type => @image.extension,
  #       :status => 200,
  #     })
  #   rescue => exception
  #     p("exception.methods----------------->", exception.methods)
  #     render ({
  #       :json => {
  #         :error => exception.message,
  #       },
  #       :content_type => "application/json",
  #       :status => 404,
  #     })
  #   end
  # end

  # 自身以外のmemberの画像を閲覧
  def show
    begin
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
        :status => 200,
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

  def update
  end

  # 指定した画像を所持しているユーザーであれば削除可能
  def delete
    p("=============================================")
    @member_id = request.headers["member-id"].to_i
    @token_for_api = request.headers["token-for-api"]
    p @member_id
    p @token_for_api

    # 削除リクエストの認証処理
    @token_check = TokenCheck.new({
      :id => @member_id,
      :token_for_api => @token_for_api,
    })
    pp(@token_check)
    # バリデーションチェック
    if @token_check.validate() != true
      raise StandardError.new "認証エラー"
    end

    response = Image.find_by({
      :id => params[:id],
      :member_id => @member_id,
    }).destroy()

    pp(response)
  rescue => exception
    p(exception)
    return render(:json => exception)
  end

  # 自身の画像をアップロードする(※非Timeline)
  def upload
    # トークンとIDの組み合わせのチェック
    @image = FormImage.new({
      :member_id => upload_params[:member_id].to_i,
      :extension => upload_params[:upload_file],
      :token_for_api => upload_params[:token_for_api].to_s,
    })
    if @image.validate != true
      raise ActiveModel::ValidationError.new(@image)
    end
    # Reset @image
    @image = nil
    # 既存レコードにuuidが存在していないかどうかを検証
    @uuid = SecureRandom.uuid
    @uuid_hash = Digest::SHA256.hexdigest @uuid
    @image = Image.find_by({
      :id => @uuid,
    })
    if @image != nil
      raise StandardError.new "UUIDの重複がありました"
    end

    @filename = @uuid_hash + "." + UtilitiesController::EXTENSION_LIST[upload_params[:upload_file].content_type]

    # アップロードファイルの確定フルパス
    uploaded_file_path = save_path.to_s + "/" + @filename
    response = FileUtils.cp(upload_params[:upload_file].tempfile.path, uploaded_file_path)

    # 仮パス -> 確定ディレクトリ へのコピー完了後
    uploaded_at = @today.strftime("%Y-%m-%d %H:%M:%S")
    random_token = TokenForApi.make_random_token 128

    new_image = {
      :id => @uuid,
      :member_id => upload_params[:member_id],
      :filename => @filename,
      :use_type => 1,
      :blur_level => 0,
      :extension => upload_params[:upload_file].content_type,
      :is_approved => true,
      :token => random_token,
      :uploaded_at => uploaded_at,
    }
    @image = Image.new(new_image)

    if @image.validate != true
      raise ActiveModel::ValidationError.new(@image)
    end

    # If validation is successfully so execute inserting new image data to table.
    @image.save
    # return
    return render :json => @image.to_json(:include => [:member])
  rescue ActiveModel::ValidationError => error
    p(error)
    return render :json => @image.errors.messages
  rescue => error
    pp error
    return render :json => error
  end

  def login_check
    return true
  end

  private

  def upload_params
    upload_params = params.fetch(:image, {
      :member_id => nil,
      :upload_file => nil,
      :token_for_api => nil,
    }).permit(
      :member_id,
      :upload_file,
      :token_for_api
    )
    return upload_params
  end

  def owner_images_params
    owner_images_params = params.permit(
      :id,
      :token_for_api
    )
    return owner_images_params
  end

  # Return absolute path to save image file uploaded by logged in user.
  def save_path
    # 画像がアップロードされた日付
    Time.zone = "Asia/Tokyo"
    @today = Time.zone.now
    # 画像のアップロード先ディレクトリ
    year = @today.strftime "%Y"
    month = @today.strftime "%m"
    day = @today.strftime "%d"
    hour = @today.strftime "%H"
    minute = @today.strftime "%M"
    # ファイルコピー先のディレクトリを確定
    decided_file_path = "storage/uploads/" + year + "/" + month + "/" + day + "/" + hour
    decided_file_path = Rails.root.join decided_file_path

    # Setting umask value.
    File.umask(0)
    FileUtils.mkdir_p decided_file_path
    return decided_file_path
  end
end
