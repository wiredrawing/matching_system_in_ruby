class LikesController < ApplicationController
  before_action :set_like, only: %i[ show edit update destroy ]

  # GET /likes or /likes.json
  def index
    @likes = Like.all
  end

  def inform
    begin
      # いいね先member_id
      to_member_id = params[:id]
      from_member_id = @current_user.id
      new_like = {
        :to_member_id => params[:id],
        :from_member_id => @current_user.id,
      }
      @like = Like.where(new_like).first()

      if @like != nil
        raise StandardError.new("既にいいねを送信済みです")
      end
      @like = Like.new(new_like)
      response = @like.save()
      print("@like =====>", @like)
      print("response ====>", response)

      # ユーザーのアクションログを記録
      @log = Log.new({
        :from_member_id => @current_user.id,
        :to_member_id => params[:id],
        :action_id => UtilitiesController::ACTION_ID_LIST[:like],
      })
      # ログ保存
      response = @log.save()

      # マッチングが完了した場合はマッチしたアクションログも残す
      if Like.is_matching?(from_member_id, to_member_id) == true
        @log = Log.new([{
          :from_member_id => @current_user.id,
          :to_member_id => params[:id],
          :action_id => UtilitiesController::ACTION_ID_LIST[:match],
        }, {
          :from_member_id => params[:id],
          :to_member_id => @current_user.id,
          :action_id => UtilitiesController::ACTION_ID_LIST[:match],
        }])
        # マッチングログを記録
        @log.save()
      end

      return redirect_to member_url(:id => params[:id])
    rescue => error
      print("Error --->", error)
      pp(error)
    end
  end

  # GET /likes/1 or /likes/1.json
  def show
  end

  # GET /likes/new
  def new
    @like = Like.new
  end

  # GET /likes/1/edit
  def edit
  end

  # POST /likes or /likes.json
  def create
    @like = Like.new(like_params)

    respond_to do |format|
      if @like.save
        format.html { redirect_to @like, notice: "Like was successfully created." }
        format.json { render :show, status: :created, location: @like }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /likes/1 or /likes/1.json
  def update
    respond_to do |format|
      if @like.update(like_params)
        format.html { redirect_to @like, notice: "Like was successfully updated." }
        format.json { render :show, status: :ok, location: @like }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /likes/1 or /likes/1.json
  def destroy
    @like.destroy
    respond_to do |format|
      format.html { redirect_to likes_url, notice: "Like was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_like
    @like = Like.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def like_params
    params.fetch(:like, {})
  end
end
