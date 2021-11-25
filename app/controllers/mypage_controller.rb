class MypageController < ApplicationController
  before_action :login_check

  def index
    pp @current_user

    # 有効なマッチング済みメンバー
    @matching_members = Like.fetch_matching_members(@current_user.id, @current_user.forbidden_members)

    # ブロック中のユーザー
    @declining_member_id_list = Decline.fetch_blocking_members(@current_user.id).map do |member|
      next member.id
    end
    # 異性のmembers一覧を取得する
    @hetero_members = Member.hetero_members(@current_user, @current_user.forbidden_members)
    return render({ :template => "mypage/index" })
  end

  def edit
    # 設定ファイルデータ
    @age_list = UtilitiesController::fetch_age_list
    @gender_list = UtilitiesController::fetch_gender_list
    @languages = UtilitiesController::fetch_language_list
    @interested_languages = UtilitiesController::fetch_interested_language_list
    @year_list = UtilitiesController::fetch_year_list
    @month_list = UtilitiesController::fetch_month_list
    @day_list = UtilitiesController::fetch_day_list

    @member = @current_user
    return render :template => "mypage/edit"
  end

  # ログインユーザーの情報更新処理
  def update
    # 設定ファイルデータ
    @age_list = UtilitiesController::fetch_age_list
    @gender_list = UtilitiesController::fetch_gender_list
    @languages = UtilitiesController::fetch_language_list
    @year_list = UtilitiesController::fetch_year_list
    @month_list = UtilitiesController::fetch_month_list
    @day_list = UtilitiesController::fetch_day_list

    @member = Member.find(self.current_user.id)
    @member.attributes = member_params_to_update

    if @member.validate() == true

      # レコードの更新処理
      @member.save()

      @member.interested_languages.destroy_all()

      if (member_params_to_update[:languages].length > 0)
        member_params_to_update[:languages].each do |lang|
          response = @member.interested_languages.new({
            :member_id => @member.id,
            :language => lang,
          }).save()
        end
      end
      redirect_to mypage_url
    else
      return render({ :template => "mypage/edit" })
    end
  rescue => error
    logger.debug error
    return render :template => "errors/index"
  end

  # ログイン中ユーザーが受けとったいいね一覧
  def getting_likes
    puts("likes =====================>")
    puts(@current_user.getting_likes)
  end

  # ログイン中ユーザーが贈ったいいね一覧
  def informing_likes
    puts("[マイページ内 informing_likes----------------------------]")
    # 除外ユーザー一覧を取得する
    excluded_members = Decline.fetch_blocking_members(@current_user.id).map do |member|
      next member.id
    end
    @informing_likes = Member.hetero_members(@current_user, excluded_members)
  end

  # 画像アップロード処理
  def upload
    @image = Image.new()
    @images = @current_user.all_images
    @blur_level = UtilitiesController::BLUR_LEVEL
    render({
      :template => "mypage/upload",
    })
  end

  def completed_uploading
    begin
      # 既存レコードにuuidが存在していないかどうかを検証
      uuid = SecureRandom.uuid
      @image = Image.find_by({
        :id => uuid,
      })

      # もし同一のuuidが既に存在していたら例外を投げる
      if @image != nil
        raise StandardError.new "UUIDの重複がありました"
      end

      # アップロードされたファイルをハッシュ化
      upload_file = params[:member][:upload_file]

      uploaded_data = {}
      # アップロード後の仮パスを取得
      uploaded_data[:temp_path] = upload_file.tempfile.path
      uploaded_data[:original_filename] = upload_file.original_filename
      uploaded_data[:extension] = upload_file.content_type

      # 画像がアップロードされた日付
      Time.zone = "Asia/Tokyo"
      today = Time.zone.now
      # 画像のアップロード先ディレクトリ
      uploaded_data[:year] = today.strftime "%Y"
      uploaded_data[:month] = today.strftime "%m"
      uploaded_data[:day] = today.strftime "%d"
      uploaded_data[:hour] = today.strftime "%H"
      uploaded_data[:minute] = today.strftime "%M"
      # ファイルコピー先のディレクトリを確定
      decided_file_path = "storage/uploads/" + uploaded_data[:year] + "/" + uploaded_data[:month] + "/" + uploaded_data[:day] + "/" + uploaded_data[:hour]
      uploaded_path = Rails.root.join decided_file_path
      # umaskの設定
      File.umask 0
      FileUtils.mkdir_p uploaded_path
      uploaded_file_path = uploaded_path.to_s + "/" + uuid
      response = FileUtils.cp uploaded_data[:temp_path], uploaded_file_path

      # 仮パス -> 確定ディレクトリ へのコピー完了後
      uploaded_at = today.strftime("%Y-%m-%d %H:%M:%S")
      random_token = self.make_random_token 64

      @image = Image.new ({
        :id => uuid,
        :member_id => @current_user.id,
        :filename => uploaded_data[:original_filename],
        :use_type => 1,
        :blur_level => 30,
        :extension => uploaded_data[:extension],
        :is_approved => true,
        :token => random_token,
        :uploaded_at => uploaded_at,
      })

      if @image.validate == true
        @image.save
        return render ({
                        :template => "mypage/upload",
                      })
      else
        render ({
          :template => "mypage/upload",
        })
      end
    rescue => error
      logger.error error
      # 例外発生時は､アップロードフォームへ再度リダイレクト
      return redirect_to mypage_upload_url
    end
  end

  def update_image
    begin
      # 更新対象の画像を取得
      params.fetch(:image, {}).permit(
        :id,
        :blur_level,
        :member_id,
      )
      @image = Image.find_by({
        :id => params[:image][:id],
        :member_id => @current_user.id,
      })
      if @image == nil
        raise StandardError.new("指定した画像が見つかりません")
      end
      response = @image.update({
        :blur_level => params[:image][:blur_level],
      })
      return redirect_to(mypage_upload_url)
    rescue => exception
      logger.debug exception
      return render :tempate => "errors/index"
    end
  end

  def delete_image
    begin
      params.fetch(:image, {}).permit(:id)
      @image = Image.find(params[:image][:id])
      @file_real_path = @image.fetch_file_path.to_s
      # まずDBレコードを削除
      response = @image.destroy()
      File.delete(@file_real_path)
      # ファイルアップロードページにリダイレクト
      return (redirect_to(mypage_upload_url))
    rescue => exception
      logger.error exception
      return (redirect_to(mypage_upload_url))
    end
  end

  # マッチング済み一覧ページ
  def matching
    @matching_members = Like.fetch_matching_members(@current_user.id)
  end

  # ブロック中一覧ページ
  def blocking
    @members_you_block = Decline.members_you_block @current_user.id
  end

  # 足跡一覧ページ
  def footprints
    @footprints = Footprint.includes(:from_member).where({
      :to_member_id => @current_user.id,
    }).order(:updated_at => :desc)

    response = @footprints.update({
      :is_browsed => UtilitiesController::BINARY_TYPE[:on],
    })
  end

  # ログアウト
  def logout
    # セッションの破棄
    session[:member_id] = nil
    # セッション破棄後､TOPページへ
    return redirect_to(top_url)
  end

  # ログインユーザーに向けられたアクションログを表示
  def logs
    @logs = Log.where({
      :to_member_id => @current_user.id,
      :is_browsed => UtilitiesController::BINARY_TYPE[:off],
    }).order(:created_at => :desc)
    @action_string_list = UtilitiesController::ACTION_STRING_LIST
  end

  private

  ##########################################
  # マイページへはログイン済みユーザーのみ許可
  ##########################################
  def login_check
    if self.logged_in? != true
      return redirect_to(login_url)
    end

    @member = @current_user
  end

  # プロフィール情報の更新時の許可リスト
  def member_params_to_update
    params.fetch(:member, {}).permit(
      :display_name,
      :family_name,
      :given_name,
      :height,
      :weight,
      :salary,
      :message,
      :memo,
      :native_language,
      :year,
      :month,
      :day,
      :languages => [],
    ).merge(:birthday => params[:member][:year] + "-" + params[:member][:month] + "-" + params[:member][:day])
  end

  # パスワード変更用のparams
  def member_params_to_change_password
    params.fetch(:member, {}).permit(
      :password_digest
    )
  end
end
