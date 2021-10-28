class MembersController < ApplicationController

  # before_action :set_member, only: %i[ show edit update destroy ]
  before_action :set_member, only: %i[ edit update destroy ]
  # メンバーページを閲覧するたびに足跡を更新する
  before_action (-> { visited_member(params[:id]) }), :only => [:show]
  # ログインしているユーザー以外かつログインユーザーの性別以外を表示
  # GET /members or /members.json

  # 閲覧可能な全メンバー一覧を表示
  def index

    # ログインユーザーがブロックしたメンバー
    @members_you_block = Decline.members_you_block(@current_user.id).map do |member|
      next member.id
    end
    # ログインユーザーをブロックしているメンバー
    @members_blocking_you = Decline.members_blocking_you(@current_user.id).map do |member|
      next member.id
    end
    # ログインユーザーがアクセスできない全メンバー
    @disable_access_members = @members_you_block + @members_blocking_you

    # 異性のmembers一覧を取得する
    @members = Member.page(params[:page]).hetero_members(@current_user, @declining_member_id_list)
  end

  # 指定した任意のmember_idの情報を表示する
  def show
    begin
      if @current_user.browsable?(params[:id]) != false
        raise StandardError.new "このメンバーを閲覧できません"
      end
      @is_yourself = false
      # 閲覧中ユーザーがログインユーザーかどうか?
      if params[:id].to_i == @current_user.id.to_i
        @is_yourself = true
        @member = Member.find params[:id]
      else
        # 自身以外のプロフィールを閲覧している場合
        # ブロックしていないかどうかをチェック
        declining = Decline.where({
          :from_member_id => @current_user.id,
          :to_member_id => params[:id],
        }).first()

        if declining != nil
          raise StandardError.new("このメンバーをブロックしています")
        end

        # ブロックされていないかどうかをチェック
        declined = Decline.where({
          :from_member_id => params[:id],
          :to_member_id => current_user.id,
        }).first()

        if declined != nil
          raise StandardError.new("このメンバーからブロックされています")
        end

        @member = Member.showable_member(@current_user, params[:id])
        # 表示可能な画像一覧のみ
        @images = @member.showable_images
      end
    rescue => error
      #--------------------------------------------
      pp(error)
      logger.debug(error)
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

  # 指定したユーザーに足跡をつける
  def visited_member(member_id)
    # ログイン中ユーザーが自身のプロフィールを見た場合を除く
    if member_id == @current_user.id
      logger.debug "#{@current_user.id}が自身のプロフィールページを閲覧しています｡"
      return nil
    end

    footprint = Footprint.where({
      :from_member_id => @current_user.id,
      :to_member_id => member_id,
    }).first()
    # logging
    logger.debug "footprint => " + footprint.to_s

    if (footprint == nil)
      # 初めてアクセスしたとき
      footprint = Footprint.new({
        :from_member_id => @current_user.id,
        :to_member_id => member_id,
        :access_count => 1,
        :is_browsed => UtilitiesController::BINARY_TYPE[:off],
      })

      # バリデーションチェック後､足跡を保存
      if footprint.validate() == true
        footprint.save()
      end
    else
      # 二回目以降のアクセス
      # updated_atとアクセス回数のみをアップデート
      updated_at = Time.new.strftime("%Y-%m-%d %H:%S") # 再訪日時
      access_count = footprint.access_count.to_i + 1 # アクセス回数
      response = footprint.update({
        :updated_at => updated_at,
        :access_count => access_count,
        :is_browsed => UtilitiesController::BINARY_TYPE[:off],
      })
    end
    # 足跡オブジェクトを返却
    return footprint
  end
end
