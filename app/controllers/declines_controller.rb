class DeclinesController < ApplicationController
  # before_action :set_decline, only: %i[ show edit update destroy ]

  # GET /declines or /declines.json
  def index
    @declines = Decline.all
  end

  # GET /declines/1 or /declines/1.json
  def show
  end

  # GET /declines/new
  def new
    @decline = Decline.new
  end

  # GET /declines/1/edit
  def edit
  end

  # POST /declines or /declines.json
  def create
    # @declineオブジェクトの作成
    @decline = Decline.new(decline_params)
    # バリデーションチェック validate()メソッドがtrueを返せば
    # バリデーションは成功している
    if @decline.validate() == true
      response = @decline.save()
      if (response == true)
        return redirect_to member_url :id => decline_params[:to_member_id]
      else
        raise StandardError.new("指定したユーザーのブロックに失敗しました")
      end
    else
      # validate()メソッドがfalseを返却した場合は
      # エラー処理を実行
      return redirect_to member_url :id => decline_params[:to_member_id]
    end
    # respond_to do |format|
    #   if @decline.save
    #     format.html { redirect_to @decline, notice: "Decline was successfully created." }
    #     format.json { render :show, status: :created, location: @decline }
    #   else
    #     format.html { render :new, status: :unprocessable_entity }
    #     format.json { render json: @decline.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /declines/1 or /declines/1.json
  def update
    respond_to do |format|
      if @decline.update(decline_params)
        format.html { redirect_to @decline, notice: "Decline was successfully updated." }
        format.json { render :show, status: :ok, location: @decline }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @decline.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /declines/1 or /declines/1.json
  def destroy
    # to_member_idキーを許可する
    params.fetch(:decline, {}).permit(
      :to_member_id,
    )
    response = Decline.destroy_by ({
                                    :from_member_id => @current_user.id,
                                    :to_member_id => params[:decline][:to_member_id],
                                  })

    if (response.length > 0)
      # 削除完了後､マイページへリダイレクト
      return redirect_to(mypage_blocking_url())
    else
      return render(:template => "error/index")
    end
  end

  private

  # # Use callbacks to share common setup or constraints between actions.
  # def set_decline
  #   print("ユーザーのブロックを解除する")
  #   p(params[:id])
  #   @decline = Decline.find(params[:id])
  # end

  # Only allow a list of trusted parameters through.
  def decline_params
    params.fetch(:decline, {}).permit(
      :to_member_id,
      :from_member_id,
    )
  end
end
