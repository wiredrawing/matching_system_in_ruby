require "uri"

class TimelineChannel < ApplicationCable::Channel
  def subscribed
    p "<------- SUBSCRIBE ----->"
    pp params
    channel = ""
    if (params["fromMemberId"].to_i < params["toMemberId"].to_i)
      channel = "timeline_channel" + params["fromMemberId"] + "-" + params["toMemberId"]
    else
      channel = "timeline_channel" + params["toMemberId"] + "-" + params["fromMemberId"]
    end
    p "channel ====", channel
    stream_from channel
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    # ActionCable.server.broadcast "timeline_channel", :message => data["message"]

    create_message_params = data[:message.to_s]
    pp (create_message_params)
    # Start transaction.
    ActiveRecord::Base.transaction do
      # メッセージからURLを抜き出す
      # @urls = URI.extract(create_message_params[:message])
      @message_to_timeline = MessageToTimeline.new ({
        :from_member_id => create_message_params[:from_member_id.to_s].to_i,
        :to_member_id => create_message_params[:to_member_id.to_s].to_i,
        :token_for_api => create_message_params[:token_for_api.to_s],
        :message => create_message_params[:message.to_s],
      })

      if @message_to_timeline.validate() != true
        raise ActiveModel::ValidationError.new(@message_to_timeline)
      end
      new_message = {
        :member_id => create_message_params["from_member_id"].to_i,
        :message => create_message_params["message"],
      }
      @message = Message.new(new_message)
      if @message.validate() != true
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
        :from_member_id => create_message_params["from_member_id"].to_i,
        :to_member_id => create_message_params["to_member_id"].to_i,
        :message_id => @message.id,
      )
      if @timeline.validate() != true
        raise StandardError.new "タイムラインのバリデーションに失敗しました"
      end
      response = @timeline.save()
      if response != true
        raise StandardError.new "タイムラインの作成に失敗しました"
      end
      # # ---------------------------------------------------------
      # # メッセージ中にURLが含まれる場合
      # # ---------------------------------------------------------
      # if @urls != nil && @urls.instance_of?(Array)

      #   # urlリストをイテレーション
      #   @urls.each do |url|
      #     @url_to_timeline = UrlToTimeline.new ({
      #       :from_member_id => create_message_params[:from_member_id].to_i,
      #       :to_member_id => create_message_params[:to_member_id].to_i,
      #       :token_for_api => create_message_params[:token_for_api],
      #       :url => url,
      #     })

      #     if @url_to_timeline.validate() == true
      #       new_url = {
      #         :member_id => create_message_params[:from_member_id],
      #         :url => url,
      #       }
      #       @url = Url.new(new_url)
      #       if @url.validate() != true
      #         raise ActiveModel::ValidationError.new @url
      #       end

      #       response = @url.save()
      #       if response != true
      #         raise StandardError.new "メッセージの投稿に失敗しました"
      #       end

      #       # タイムラインオブジェクトを作成
      #       @timeline = Timeline.includes(:message).new(
      #         :from_member_id => create_message_params[:from_member_id],
      #         :to_member_id => create_message_params[:to_member_id],
      #         :url_id => @url.id,
      #       )
      #       if @timeline.validate() != true
      #         raise StandardError.new "タイムラインのバリデーションに失敗しました"
      #       end
      #       response = @timeline.save()
      #       if response != true
      #         raise StandardError.new "タイムラインの作成に失敗しました"
      #       end
      #     end
      #   end
      # end

      # Saved executed process on above as log.
      @log = Log.new({
        :from_member_id => create_message_params["from_member_id"].to_i,
        :to_member_id => create_message_params["to_member_id"].to_i,
        :action_id => UtilitiesController::ACTION_ID_LIST[:message],
      })
      if @log.validate() != true
        raise ActiveModel::ValidationError.new @log
      end

      if @log.save() != true
        raise StandardError.new "ログの保存に失敗しました"
      end

      # ブロードキャスト処理を実装
      channel = ""
      json_response = {
        :status => true,
        :response => {
          :timeline => @timeline,
        },
        :file_name => __FILE__,
      }

      if (@timeline[:from_member_id] < @timeline[:to_member_id])
        channel = "timeline_channel" + @timeline[:from_member_id].to_s + "-" + @timeline[:to_member_id].to_s
      else
        channel = "timeline_channel" + @timeline[:to_member_id].to_s + "-" + @timeline[:from_member_id].to_s
      end
      ActionCable.server.broadcast channel, json_response
    end
  rescue => error
    logger.error error
    return error.message
  end
end
