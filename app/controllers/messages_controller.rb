class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ]

  def index
    puts("[メッセージ一覧-------------------------------------]")
    # ログインユーザーが受け取った異性ごとのメッセージ
    @timelines_to = Timeline.select(
      "max(id) as id ",
      "max(created_at) as created_at"
    ).where({
      :to_member_id => @current_user.id,
    }).limit(
      10
    ).group(
      :from_member_id,
    ).to_a.map do |timeline|
      next timeline.id
    end

    @timelines = Timeline.where({
      :id => @timelines_to,
    })
    return render :template => "messages/index"
  end

  def talk
    @matching_members = Like.fetch_matching_members(@current_user.id).map do |member|
      next member.id
    end
    if @matching_members.include?(params[:id].to_i) != true
      raise StandardError.new "メッセージ相手が見つかりませんでした"
    end

    # メッセージ相手のメンバー情報
    @opponent = Member.find(params[:id])
    if @opponent == nil
      raise StandardError.new "メッセージ相手が見つかりませんでした"
    end

    # 現時点までの､メッセージのやり取りデータを取得する
    @timeline_id_list = Timeline.where({
      :from_member_id => @current_user.id,
      :to_member_id => params[:id],
    }).or(
      Timeline.where({
        :from_member_id => params[:id],
        :to_member_id => @current_user.id,
      })
    ).to_a.map do |timeline|
      next timeline.id
    end

    # 閲覧中のメンバー同士の発言のみを取得
    @to_member_id = params[:id]

    @timelines = Timeline.where({
      :id => @timeline_id_list,
    }).order(
      :created_at => :desc,
    ).limit(10)

    @timelines = @timelines.sort do |a, b|
      a.id <=> b.id
    end

    pp @timelines
    # 任意のテンプレート
    return render :template => "messages/talk"
  rescue => error
    pp(error)
    return false
  end

  # 入力内容をレコードに新規追加する
  def create
    puts("[新規メッセージを登録する]")
    pp(params)
    params.fetch(:message, {}).permit(
      :from_member_id,
      :to_member_id,
      :message
    )
    @message = Message.new({
      :member_id => @current_user.id,
      :message => params[:message][:message],
    })

    if @message.validate() != true
      raise StandardError.new "メッセージを送信できませんでした"
    end

    response = @message.save()

    @timeline = Timeline.new({
      :from_member_id => @current_user.id,
      :to_member_id => params[:message][:to_member_id],
      :message_id => @message.id,
    })

    if @timeline.validate() != true
      raise StandardError.new "タイムラインの保存に失敗しました"
    end

    @timeline.save()

    return redirect_to(message_talk_url :id => params[:message][:to_member_id])
  rescue => exception
    pp(exception)
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # # POST /messages or /messages.json
  # def create
  #   @message = Message.new(message_params)

  #   respond_to do |format|
  #     if @message.save
  #       format.html { redirect_to @message, notice: "Message was successfully created." }
  #       format.json { render :show, status: :created, location: @message }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @message.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def message_params
    params.fetch(:message, {})
  end
end
