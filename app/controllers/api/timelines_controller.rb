class Api::TimelinesController < ApplicationController

  # csrfを除外するmethod
  protect_from_forgery :except => :create_message

  # 過去のメッセージのやりとり一覧を取得
  def message_list

    # メッセージリストのリクエストユーザーの認証
    @token_check = TokenCheck.new({
      :id => request.headers["member-id"].to_i,
      :token_for_api => request.headers["token-for-api"],
    })

    if @token_check.validate() != true
      raise ActiveModel::ValidationError.new @token_check
    end

    @timelines = Timeline.where({
      :from_member_id => params[:from_member_id].to_i,
      :to_member_id => params[:to_member_id].to_i,
    })
      .order(:created_at => :desc)
      .limit(5)

    if @timelines.first == nil
      raise StandardError.new "メッセージのやりとりは有りません"
    end

    # メッセージをIDのasc順に再度並び替え
    @timelines = @timelines.sort do |a, b|
      if a.id > b.id
        next 1
      elsif a.id < b.id
        next -1
      else
        next 0
      end
    end

    render({
      :json => @timelines.to_json({
        :include => [
          :message,
          :image,
          :url,
        ],
      }),
    })
    return true
  rescue ActiveModel::ValidationError => error
    p error.model
    p error.class
    return render(:json => error.model.errors.messages)
  rescue => error
    p error.message
    return render(:json => error.message)
  end

  # メッセージの投稿
  def create_message
    ActiveRecord::Base.transaction do
      @message_to_timeline = MessageToTimeline.new ({
        :from_member_id => create_message_params[:from_member_id].to_i,
        :to_member_id => create_message_params[:to_member_id].to_i,
        :token_for_api => create_message_params[:token_for_api],
        :message => create_message_params[:message],
      })

      if @message_to_timeline.validate() != true
        raise ActiveModel::ValidationError.new(@message_to_timeline)
      end

      # raise StandardError.new "意図的な例外"
      # 新規メッセージを作成
      new_message = {
        :member_id => create_message_params[:from_member_id],
        :message => create_message_params[:message],
      }
      @message = Message.new(new_message)
      if @message.validate() != true
        p @message.errors.messages
        @message.methods.each do |method|
          if (method == :errors)
            p "==========================>"
          end
        end
        p "---"
        p @message.errors.messages
        p "==="
        errors = @message.errors.messages
        p errors
        raise ActiveModel::ValidationError.new @message
        p "ああああああ"
        # raise StandardError.new "メッセージのバリデーションに失敗しました"
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
  rescue ActiveModel::ValidationError => error
    logger.debug error.model.errors.messages
    return render({ :json => error.model.errors.messages })
  rescue => exception
    puts("[例外発生-----------------------------------]")
    p(exception)
    p(exception.message)
    # pp @message_to_timeline.errors.messages
    # return render :json => @message_to_timeline.errors.messages
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
