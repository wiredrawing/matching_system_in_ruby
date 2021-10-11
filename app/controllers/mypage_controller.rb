require 'fileutils'
class MypageController < ApplicationController
  before_action :login_check

  def index
    return render({ :template => "mypage/index" })
  end

  def edit
    p "MypageController#edit =="
    return render ({ :template => "mypage/edit" })
  end

  # ログインユーザーの情報更新処理
  def update
    @member = Member.find(self.member_params[:id])
    @member.attributes = {
      # :id => member_params[:id],
      # :email => member_params[:email],
      :display_name => member_params[:display_name],
      :family_name => member_params[:family_name],
      :given_name => member_params[:given_name],
      :gender => member_params[:gender],
      :height => member_params[:height],
      :weight => member_params[:weight],
      :birthday => member_params[:birthday],
      :salary => member_params[:salary],
      :message => member_params[:member],
      :memo => member_params[:memo],
    }
    # バリデーション成功の場合はMyPageトップへリダイレクト
    if (@member.validate) == true
      @member.save
      return redirect_to mypage_url
    else
      return render({ :template => "mypage/edit" })
    end
  end


  # 画像アップロード処理
  def upload

    return render ({
      :template => "mypage/upload",
    })
  end

  def completed_uploading
    # アップロードされたファイルをハッシュ化
    p 'params ---->', params
    uploaded_data = {}
    uploaded_data[:upload_file] = params[:member][:upload_file]
    uploaded_data[:upload_file_name] = params[:member][:upload_file].original_filename
    uploaded_data[:extension] = params[:member][:upload_file].content_type
    p 'uploaded_data------------------------>', uploaded_data
    # 画像がアップロードされた日付
    Time.zone = "Asia/Tokyo"
    today = Time.zone.now
    uploaded_data[:year] = today.strftime "%Y"
    uploaded_data[:month] = today.strftime "%m"
    uploaded_data[:day] = today.strftime "%d"
    uploaded_data[:hour] = today.strftime "%H"
    uploaded_data[:minute] = today.strftime "%M"
    # 画像のアップロード先ディレクトリ
    uuid = SecureRandom.uuid
    uploaded_path = Rails.root.join("storage/uploads/" +
                                      uploaded_data[:year] + "/" +
                                      uploaded_data[:month] + "/" +
                                      uploaded_data[:hour] + "/" +
                                      uploaded_data[:minute] + "/"
                                    )
    # umaskの設定
    File.umask 0
    response_dir = FileUtils . mkdir_p (uploaded_path)

    uploaded_file_path = uploaded_path.to_s + "/" + uuid
    File.open uploaded_file_path, "w+b" do | fp |
      _temp = fp . write uploaded_data[:upload_file].read
      p '_temp ---->' , _temp
    end

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

  def member_params
    params.fetch(:member, {}).permit(
      :id,
      :email,
      :display_name,
      :family_name,
      :given_name,
      :gender,
      :height,
      :weight,
      :birthday,
      :salary,
      :message,
      :memo,
      :password,
      :password_confirmation,
      :password_digest
    )
  end
end
