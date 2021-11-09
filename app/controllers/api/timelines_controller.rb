class Api::TimelinesController < ApplicationController

  # csrfを除外するmethod
  protect_from_forgery :except => [
    :create_message,
    :create_image,
  ]

  # 過去のメッセージのやりとり一覧を取得
  def messages
    # メッセージリストのリクエストユーザーの認証
    @token_check = TokenCheck.new({
      :id => request.headers["member-id"].to_i,
      :token_for_api => request.headers["token-for-api"],
    })

    if @token_check.validate() != true
      raise ActiveModel::ValidationError.new @token_check
    end

    @timeline_id_list = Timeline.where({
      :from_member_id => params[:from_member_id].to_i,
      :to_member_id => params[:to_member_id].to_i,
    }).or(Timeline.where({
      :from_member_id => params[:to_member_id].to_i,
      :to_member_id => params[:from_member_id].to_i,
    })).map do |timeline|
      next timeline.id
    end

    @timelines = Timeline.includes(
      :image,
      :message,
      :url,
      :from_member,
      :to_member,
    ).where({
      :id => @timeline_id_list,
    }).order(
      :created_at => :desc,
    ).limit(params[:limit].to_i)
      .offset(params[:offset].to_i)

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

    return render(:json => @timelines.to_json({
                    :include => [
                      :message,
                      :image,
                      :url,
                    ],
                  }))
  rescue ActiveModel::ValidationError => error
    logger.debug "#{error.model.errors.messages.join(",")}"
    return render(:json => error.model.errors.messages)
  rescue => error
    logger.debug "#{error.message}"
    return render(:json => error.message)
  end

  # メッセージの投稿
  def create_message
    # Start transaction.
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

      new_message = {
        :member_id => create_message_params[:from_member_id],
        :message => create_message_params[:message],
      }
      @message = Message.new(new_message)
      if @message.validate() != true
        # p @message.errors.messages
        # @message.methods.each do |method|
        #   if (method == :errors)
        #     p "==========================>"
        #   end
        # end

        # errors = @message.errors.messages
        raise ActiveModel::ValidationError.new @message
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

      # pp @timeline.methods
      json_response = {
        :status => true,
        :response => {
          :timeline => @timeline,
        },
      }
      render :json => json_response
    end
  rescue ActiveModel::ValidationError => error
    logger.debug error.model.errors.messages
    json_response = {
      :status => false,
      :response => error.model.errors.messages,
    }
    return render({ :json => json_response })
  rescue => exception
    puts("[例外発生-----------------------------------]")
    pp exception.backtrace.methods
    p(exception)
    p(exception.message)
    # pp @message_to_timeline.errors.messages
    # return render :json => @message_to_timeline.errors.messages
  end

  # 画像の投稿
  def create_image
    upload_params = {
      :member_id => create_image_params[:from_member_id].to_i,
      :upload_file => create_image_params[:upload_file],
      :is_displayed => UtilitiesController::BINARY_TYPE[:on],
      :token_for_api => request.headers["token-for-api"],
    }
    # アップロード処理を実行
    # アップロードによる最新のimage_idを取得
    @image_id = self.upload_process(upload_params)
    p "@image_id ===============================>", @image_id
    @timeline = Timeline.new({
      :from_member_id => create_image_params[:from_member_id].to_i,
      :to_member_id => create_image_params[:to_member_id].to_i,
      :message_id => nil,
      :url_id => nil,
      :image_id => @image_id,
    })

    if @timeline.validate() != true
      raise ActiveModel::ValidationError.new @timeline
    end
    response = @timeline.save()
    p response

    json_response = {
      :status => true,
      :response => {
        :timeline => @timeline
      }
    }
    return render :json => json_response
    # return render :json => @timeline.to_json(:include => [
    #                                            :message,
    #                                            :image,
    #                                            :url,
    #                                          ])
  rescue ActiveModel::ValidationError => error
    p error.backtrace
    return render :json => error.model.errors.messages
  rescue => error
    p error.backtrace
    return render :json => error.message
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

  def create_image_params
    create_image_params = params.fetch(:image, {}).permit(
      :from_member_id,
      :to_member_id,
      :upload_file,
      :token_for_api,
    )
    return create_image_params
  end
end
