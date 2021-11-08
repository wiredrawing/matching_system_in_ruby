module Api::ImagesHelper
  def upload_process(parameters)

    # 表示スタータスが設定されていない場合は1を代入
    parameters[:is_displayed] ||= UtilitiesController::BINARY_TYPE[:on]

    # トークンとIDの組み合わせのチェック
    @image = FormImage.new({
      :member_id => parameters[:member_id].to_i,
      :extension => parameters[:upload_file],
      :token_for_api => parameters[:token_for_api].to_s,
    })
    # Check validation of post data.
    if @image.validate != true
      raise ActiveModel::ValidationError.new(@image)
    end
    # Make variable named '@image' nil.
    remove_instance_variable :@image

    # 既存レコードにuuidが存在していないかどうかを検証
    @uuid = SecureRandom.uuid
    @uuid_hash = Digest::SHA256.hexdigest @uuid
    @image = Image.find_by({
      :id => @uuid,
    })
    if @image != nil
      raise StandardError.new "UUIDの重複がありました"
    end

    # Make file name wtih hash text from uuid maded by random function.
    @filename = @uuid_hash + "." + UtilitiesController::EXTENSION_LIST[parameters[:upload_file].content_type]

    # アップロードファイルの確定フルパス
    uploaded_file_path = save_path.to_s + "/" + @filename
    response = FileUtils.cp(parameters[:upload_file].tempfile.path, uploaded_file_path)

    # 仮パス -> 確定ディレクトリ へのコピー完了後
    uploaded_at = @today.strftime("%Y-%m-%d %H:%M:%S")
    random_token = TokenForApi.make_random_token 128

    @image = Image.new({
      :id => @uuid,
      :member_id => parameters[:member_id],
      :filename => @filename,
      :use_type => 1,
      :blur_level => 0,
      :extension => parameters[:upload_file].content_type,
      :is_approved => UtilitiesController::BINARY_TYPE[:on],
      :is_displayed => parameters[:is_displayed],
      :token => random_token,
      :uploaded_at => uploaded_at,
    })

    if @image.validate != true
      raise ActiveModel::ValidationError.new(@image)
    end

    # If validation is successfully so execute inserting new image data to table.
    if (@image.save != true)
      raise StandardError.new "画像のアップロードに失敗しました"
    end
    # Return the new uuid on images table.
    return @image.id
    # rescue ActiveModel::ValidationError => error
    #   p error.backtrace
    #   logger.debug error.model.errors.messages
    #   # return render :json => error.model.errors.messages
    #   return nil
    # rescue => error
    #   p error.backtrace
    #   logger.debug error.message
    #   return nil
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
