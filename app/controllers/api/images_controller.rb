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
      :use_type => UtilitiesController::USE_TYPE_LIST[:profile],
    }).order(:created_at => :desc)

    return render :json => @images.to_json(:include => [
                                             :member,
                                             :member_blongs_to,
                                           ])
  rescue => exception
    logger.error exception
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
      :is_displayed => Constants::Binary::Type[:on],
      :is_deleted => Constants::Binary::Type[:off],
    }).order(:created_at => :desc)

    return render :json => @images.to_json
  rescue => exception
    logger.error exception
    return render :json => @token_check.errors.messages
  end

  # Show the images published by owner.
  def image_url
    @errors = Array.new()
    @image = Image.find_by({
      :id => params[:id],
      :token => params[:token],
      :is_displayed => Constants::Binary::Type[:on],
      :is_deleted => Constants::Binary::Type[:off],
    })
    if @image == nil
      raise StandardError.new @errors.push("画像がみつかりません")
    end

    # Fetch a filepath of raw an image.
    original = @image.fetch_file_path

    # If blur level is greater than zero, return resource scaled an image.
    if @image.blur_level > 0
      # Return resized image.
      return render :file => original.to_s + ".resize", :content_type => @image.extension, :status => 200
    end
    return render :file => original, :content_type => @image.extension, :status => 200
  rescue => exception
    logger.debug "#{exception.message}"
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

    original = @image.fetch_file_path
    # If blur level is greater than zero, return resource scaled an image.
    if @image.blur_level > 0
      # img = Magick::ImageList.new(original)
      # resize_img = img.blur_image(@image.blur_level, @image.blur_level)
      # resize_img = resize_img.write(original.to_s + ".resize")
      return render :file => original.to_s + ".resize", :content_type => @image.extension, :status => 200
    end
    return render :file => original, :content_type => @image.extension, :status => 200
  rescue => exception
    return render :json => exception.message
  end

  def update
    # ログインユーザーの認証チェック
    @member_id = request.headers["member-id"].to_i
    @token_for_api = request.headers["token-for-api"]
    @token_check = TokenCheck.new({
      :id => @member_id,
      :token_for_api => @token_for_api,
    })

    # 認証バリデーション
    if @token_check.validate() != true
      raise StandardError.new "認証用トークンがマッチしません"
    end

    @image = Image.find(update_params[:id])

    if @image == nil
      raise StandardError.new "画像データが見つかりません"
    end

    # Update blur level and display status.
    response = @image.update({
      :blur_level => update_params[:blur_level],
      :is_displayed => update_params[:is_displayed],
    })
    if response != true
      raise StandardError.new "画像の更新に失敗しました"
    end

    original = @image.fetch_file_path
    # If blur level is greater than zero, return resource scaled an image.
    if @image.blur_level > 0
      img = Magick::ImageList.new(original)
      resize_img = img.blur_image(@image.blur_level, @image.blur_level)
      resize_img = resize_img.write(original.to_s + ".resize")
      return render :file => original.to_s + ".resize", :content_type => @image.extension, :status => 200
    end
    return render :file => original, :content_type => @image.extension, :status => 200
  rescue => exception
    logger.error exception
    return render :json => exception.message
  end

  # 指定した画像を所持しているユーザーであれば削除可能
  def delete
    @member_id = request.headers["member-id"].to_i
    @token_for_api = request.headers["token-for-api"]

    # 削除リクエストの認証処理
    @token_check = TokenCheck.new({
      :id => @member_id,
      :token_for_api => @token_for_api,
    })
    # バリデーションチェック
    if @token_check.validate() != true
      raise StandardError.new "認証エラー"
    end

    response = Image.find_by({
      :id => params[:id],
      :member_id => @member_id,
    }).destroy()
  rescue => exception
    logger.error exception
    return render(:json => exception)
  end

  # 自身の画像をアップロードする(※非Timeline)
  def upload
    @image_id = self.upload_process(upload_params)

    @image = Image.find(@image_id)
    if @image == nil
      raise StandardError.new "ファイルアップロードに失敗しました"
    end
    return render :json => @image.to_json(:includes => [:member])
  rescue ActiveModel::ValidationError => error
    # logger.debug "111[例外]---#{error.message.to_s}"
    logger.error error
    return render :json => @image.errors.messages
  rescue => error
    logger.error error
    return render :json => error.message
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
      :use_type => UtilitiesController::USE_TYPE_LIST[:profile],
    }).permit(
      :member_id,
      :upload_file,
      :token_for_api,
      :use_type => UtilitiesController::USE_TYPE_LIST[:profile],
    )
    return upload_params
  end

  def update_params
    update_params = params.fetch(:image, {
      :id => nil,
      :blur_level => nil,
      :is_displayed => nil,
    }).permit(
      :id,
      :blur_level,
      :is_displayed,
    )
    return update_params
  end

  def owner_images_params
    owner_images_params = params.permit(
      :id,
      :token_for_api
    )
    return owner_images_params
  end
end
