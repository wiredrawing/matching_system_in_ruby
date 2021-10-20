class MembersController < ApplicationController

  # before_action :set_member, only: %i[ show edit update destroy ]
  before_action :set_member, only: %i[ edit update destroy ]
  # ログインしているユーザー以外かつログインユーザーの性別以外を表示
  # GET /members or /members.json
  def index
    # 異性のmembers一覧を取得する
    @members = Member.hetero_members(@current_user)
  end

  # 指定した任意のmember_idの情報を表示する
  def show
    begin
      # ブロックしていないかどうかをチェック
      declining = Decline.where({
        :from_member_id => @current_user.id,
        :to_member_id => params[:id],
      }).first()

      print("ブロックしているかどうかをチェック")
      p(declining)
      if declining != nil
        raise StandardError.new("このメンバーをブロックしています")
      end

      # ブロックされていないかどうかをチェック
      declined = Decline.where({
        :from_member_id => params[:id],
        :to_member_id => current_user.id
      }).first()

      print("ブロックされていないかどうかをチェック")
      p(declined)
      if declined != nil then
        raise StandardError.new("このメンバーからブロックされています")
      end

      puts("aaaaaaaaaaaaaaaaa")
      @member = Member.showable_member(@current_user, params[:id])
      print(@member.class)
      puts("もらったいいね ===>", @member.getting_likes)
      puts("もらったいいねの数 ===>", @member.getting_likes.length)
      print("@member.display_name ---->", @member.display_name)
      puts("show ===================================")
      p(@member)
      puts("閲覧中ユーザーがアップロードしている画像")
      p(@member.showable_images)
      p(@member.all_images)
      # 公開中の画像一覧を取得する
      # @images = @member.images.where ({
      #   :is_displayed => UtilitiesController::BINARY_TYPE[:on],
      #   :is_deleted => UtilitiesController::BINARY_TYPE[:off],
      # })
      # 表示可能な画像一覧のみ
      @images = @member.showable_images
      print("公開中の画像一覧を取得する=================>")
      puts(@images.length)
    rescue => error
      puts("例外発生!!!!!!!!!!!")
      puts(error)
      render({
        :template => "members/error",
      })
    end
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members or /members.json
  def create
    @genders = [
      ["未設定", 0],
      ["男性", 1],
      ["女性", 2],
    ]

    p "member_params -->", member_params
    p "parms -->", params
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: "Member was successfully created." }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1 or /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: "Member was successfully updated." }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1 or /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url, notice: "Member was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_member
    @member = Member.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def member_params
    # createメソッドで登録許可される値
    params.fetch(:member, {})
      .permit(
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
        :password_digest
      )
  end
end
