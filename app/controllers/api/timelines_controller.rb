class Api::TimelinesController < ApplicationController

  # csrfを除外するmethod
  protect_from_forgery :except => :create_message

  # メッセージの投稿
  def create_message
    ActiveRecord::Base.transaction do
      puts("メッセージの送信用API実行開始---------------")
      @message_to_timeline = MessageToTimeline.new(create_message_params)
      if @message_to_timeline.validate() != true
        raise ActiveModel::ValidationError.new(@message_to_timeline)
      end

      # 新規メッセージを作成
      new_message = {
        :member_id => create_message_params[:from_member_id],
        :message => create_message_params[:message],
      }
      @message = Message.new(new_message)
      if @message.validate() != true
        raise StandardError.new "メッセージのバリデーションに失敗しました"
      end
      response = @message.save()
      if response != true
        raise StandardError.new "メッセージの投稿に失敗しました"
      end

      # タイムラインオブジェクトを作成
      @timeline = Timeline.includes(:message).new(
        :from_member_id => create_message_params[:from_member_id],
        :to_member_id => create_message_params[:to_member_id],
        :message_id => @message.id,
      )
      if @timeline.validate() != true
        raise StandardError.new "タイムラインのバリデーションに失敗しました"
      end

      response = @timeline.save()
      if response != true
        raise StandardError.new "タイムラインの作成に失敗しました"
      end
      render(:json => @timeline.to_json(:include => [
                                          :message,
                                        ]))
    end
  rescue ActiveModel::ValidationError => vaildation_error
    # バリデーションエラーをjson配列で返却する
    render(:json => @message_to_timeline.errors.messages)
  rescue => exception
    puts("[例外発生-----------------------------------]")
    p(exception)
    p(exception.message)
    pp message_to_timeline.errors.messages
    return true
  end

  # 要ログインを一旦外す場合
  def login_check
    return true
  end

  private

  def create_message_params
    params.fetch(:message, {}).permit(
      :from_member_id,
      :to_member_id,
      :message,
      :token_for_api
    )
  end
end
