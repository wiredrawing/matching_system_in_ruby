require "fileutils"

class MypageController < ApplicationController
  before_action :login_check

  def index
    # 現在マッチング中のメンバーを取得
    @matching_members = Like.fetch_matching_members(@current_user.id)
    puts("matching_members ====>")
    p(@matching_members)
    return render({ :template => "mypage/index" })
  end

  def edit
    return render ({ :template => "mypage/edit", :aa => :aa })
  end

  # ログインユーザーの情報更新処理
  def update
    @member = Member.find(self.current_user.id)
    # 更新対象のカラムをオブジェクトにアサイン
    @member.attributes = member_params_to_update

    # バリデーション成功の場合はMyPageトップへリダイレクト
    _valid = @member.validate()
    if _valid == true
      # レコードの更新処理
      @member.save()
      redirect_to mypage_url
    else
      render({ :template => "mypage/edit" })
    end
  end

  # ログイン中ユーザーが受けとったいいね一覧
  def likes
    puts("likes =====================>")
    puts(@current_user.getting_likes)
  end

  # 画像アップロード処理
  def upload
    @image = Image.new()
    @images = Image.where({
      :member_id => @current_user.id,
    })
    render ({
      :template => "mypage/upload",
    })
  end

  def completed_uploading
    begin
      # 既存レコードにuuidが存在していないかどうかを検証
      uuid = SecureRandom.uuid
      p("アプリケーション側で生成したUUID =====>", uuid)
      @image = Image.find_by({
        :id => uuid,
      })

      # もし同一のuuidが既に存在していたら例外を投げる
      if @image != nil
        raise StandardError.new "UUIDの重複がありました"
      end

      p "@image ---> ", @image

      p "params[:member] -------------------> ", params[:member]

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
        # バリデーション失敗時はエラー内容の表示処理
        p "@image ----------------------->", @image
        p "response ---->", response
        p "@image.errors.messages ---> ", @image.errors.messages
        render ({
          :template => "mypage/upload",
        })
      end
    rescue => error
      # 例外発生時は､アップロードフォームへ再度リダイレクト
      p "rescue ======>  ", error
      return redirect_to mypage_upload_url
    end
  end

  def delete_image
    print("delete_image ==========================>")
    params.fetch(:image, {}).permit(:id)
    @image = Image.find(params[:image][:id])
    @file_real_path = @image.fetch_file_path.to_s
    # まずDBレコードを削除
    response = @image.destroy()
    p("削除したレコード ====>", response)
    p(@image.fetch_file_path)
    p("ファイルの物理削除 ====>", File.delete(@file_real_path))
    p(params)
    p(@image)
    # ファイルアップロードページにリダイレクト
    return (redirect_to(mypage_upload_url))
  end

  # マッチング済み一覧ページ
  def matching
    @matching_members = Like.fetch_matching_members(@current_user.id)
  end

  # ブロック中一覧ページ
  def blocking
    @declining_members = Decline.fetch_blocking_members(@current_user.id)
    print("ブロック中のメンバー一覧")
    p(@declining_members)
  end

  # 足跡一覧ページ
  def footprints
    @footprints = Footprint.where({
      :to_member_id => @current_user.id,
    }).order(:updated_at => :desc)

    print("ここはログインユーザーへの足跡一覧ページです")
    p(@footprints)
    p(@footprints.class)
    p(@footprints.methods)
  end

  private

  ##########################################
  # マイページへはログイン済みユーザーのみ許可
  ##########################################
  def login_check
    p "======================================================"
    p "MypageController#login_check"
    p "self.logged_in?=======>", self.logged_in?
    p "self.current_user ====>", self.current_user
    p "======================================================"
    if self.logged_in? != true
      return redirect_to(signin_url)
    end

    p "@current_user ===>", @current_user
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
    )
  end

  # パスワード変更用のparams
  def member_params_to_change_password
    params.fetch(:member, {}).permig(
      :password_digest
    )
  end
end
