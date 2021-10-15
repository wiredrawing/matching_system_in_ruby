class MembersController < ApplicationController
  GENDER_LIST = [
    { :id => 0, :data => "未設定" },
    { :id => 1, :data => "男性" },
    { :id => 2, :data => "女性" },
  ]
  # before_action :set_member, only: %i[ show edit update destroy ]
  before_action :set_member, only: %i[ edit update destroy ]
  # ログインしているユーザー以外かつログインユーザーの性別以外を表示
  # GET /members or /members.json
  def index
    @members = Member.where.not({
      :id => @current_user.id,
    }).where.not({
      :gender => @current_user.gender,
    })
  end

  # GET /members/1 or /members/1.json
  def show
    puts("---------------------------------------------")
    begin

      # 本登録完了済みのユーザーのみを取得する
      @member = Member.find_by({
        :id => params[:id],
        :is_registered => UtilitiesController::BINARY_TYPE[:on],
      })

      if @member == nil
        raise StandardError.new("指定したユーザーが見つかりませんでした")
      end
    rescue => exception
      puts("happen exception! ---------------------------------------")
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
