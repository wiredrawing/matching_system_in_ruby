class LikesController < ApplicationController
  before_action :set_like, only: %i[ show edit update destroy ]

  # GET /likes or /likes.json
  def index
    @likes = Like.all
  end

  def inform
    ActiveRecord::Base.transaction do
      # いいね先member_id
      to_member_id = params[:id]
      from_member_id = @current_user.id

      # 新規挿入レコード
      new_like = {
        :to_member_id => params[:id],
        :from_member_id => @current_user.id,
      }

      # レコードの重複チェック
      if Like.find_by(new_like) != nil
        raise StandardError.new "既に登録済みです"
      end

      # レコード挿入処理
      @like = Like.new(new_like)
      if @like.save() != true
        raise StandardError.new "いいねの送信に失敗しました"
      end

      # ユーザーのアクションログを記録
      new_log = {
        :from_member_id => @current_user.id,
        :to_member_id => params[:id],
        :action_id => UtilitiesController::ACTION_ID_LIST[:like],
      }
      @log = Log.new(new_log)

      # ログ保存
      if @log.save() != true
        raise StandardError.new "いいねの送信は成功しましたが､ログの保存に失敗しました"
      end

      # マッチングが完了した場合はマッチしたアクションログも残す
      if Like.is_matching?(from_member_id, to_member_id) == true
        # ログ登録1回目
        @log = Log.new({
          :from_member_id => @current_user.id,
          :to_member_id => params[:id],
          :action_id => UtilitiesController::ACTION_ID_LIST[:match],
        })
        if @log.save() != true
          raise StandardError.new("マッチングログの登録に失敗しました")
        end

        # ログ登録回目
        @log = Log.new({
          :from_member_id => params[:id],
          :to_member_id => @current_user.id,
          :action_id => UtilitiesController::ACTION_ID_LIST[:match],
        })
        if @log.save() != true
          raise StandardError.new("マッチングログの登録に失敗しました")
        end
      end
      return redirect_to member_url(:id => params[:id])
    end
  rescue => error
    p "[例外発生--------------------------------------------------]"
    pp error
    logger.debug "[例外発生] #{error.message}"
    ActiveRecord::Rollback
    return redirect_to member_url(:id => params[:id])
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
