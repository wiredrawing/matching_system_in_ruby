class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ]

  # 現時点で､メッセージ可能なメンバーリストを表示
  def index
    @matching_members = Like.fetch_matching_members(@current_user.id, @current_user.forbidden_members).to_a.map do |member|
      next member.id
    end

    @members = Member.select([
      :id,
      :display_name,
      "max(timelines.created_at) as timeline_created_at",
    ]).where({
      :id => @matching_members,
    }).joins(%{LEFT JOIN timelines on timelines.from_member_id = members.id and timelines.to_member_id = #{@current_user.id}})
      .group([
        :id,
        :display_name,
      ]).order("timeline_created_at desc nulls last")

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
    return render :template => "errors/index"
  end

  # 入力内容をレコードに新規追加する
  def create
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
    logger.info exception
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
