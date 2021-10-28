class Api::TimelinesController < ApplicationController

  # メッセージの投稿
  def create_message
    params.fetch(:message, {}).permit(
      :from_member_id,
      :to_member_id,
      :message,
    )
    # 新規メッセージを作成
    new_message = {
      :member_id => @current_user.id,
      :message => params[:message][:message],
    }
    # メッセージオブジェクトの作成
    @message = Message.new(new_message)

    if @message.validate() != true
      raise StandardError.new "メッセージの投稿に失敗しました"
    end

    # メッセージをテーブルに保存
    response = @message.save()
    @message_id = @message.id

    # タイムラインオブジェクトを作成
    @timeline = Timeline.new(
      :from_member_id => @current_user.id,
      :to_member_id => params[:message][:to_member_id],
      :message_id => @message_id,
    )
    if @timeline.validate() != true
      raise StandardError.new "タイムラインの作成に失敗しました"
    end
  rescue => exception
    errors = @message.errors.messages.each do |error|
      p(error)
    end
    pp(errors)
    logger.debug exception
    puts("[例外発生----------------------------------------]")
    pp(exception)

    # バリデーションエラーをjsonで返却する
    return @message.errors.messages
  end

  # 要ログインを一旦外す場合
  def login_check
    return true
  end
end
