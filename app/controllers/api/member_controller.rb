class Api::MemberController < ApplicationController

  # 指定したmember_idにマッチするメンバー情報を取得する
  def show
    p ("===========================")
    p request.headers["member-id"]
    p request.headers["token-for-api"]
    # Check authorization.
    @token_check = TokenCheck.new({
      :id => request.headers["member-id"].to_i,
      :token_for_api => request.headers["token-for-api"],
    })
    p @token_check
    if @token_check.validate() != true
      raise AcitveModel::ValidationError.new @token_check
    end

    @member = Member.find(params[:id])

    if @member == nil
      @errors.push("メンバー情報が取得できませんでした")
      raise StandardError.new "メンバー情報が取得できませんでした"
    end

    json_response = {
      :status => true,
      :response => {
        :member => @member,
      },
      :errors => nil,
    }
    return render :json => json_response
  rescue ActiveModel::ValidationError => error
    p error
    json_response = {
      :status => false,
      :response => [],
      :errors => error.model.errors.messages,
    }
  rescue => error
    p error
    json_reponse = {
      :status => false,
      :response => [],
      :errors => @errors,
    }
    return render :json => json_reponse
  end

  def login_check
    return true
  end
end
