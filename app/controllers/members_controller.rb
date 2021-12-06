class MembersController < ApplicationController

  # before_action :set_member, only: %i[ show edit update destroy ]
  before_action :set_member, only: %i[ edit update destroy ]
  # メンバーページを閲覧するたびに足跡を更新する
  before_action (-> { visited_member(params[:id]) }), :only => [:show]
  # ログインしているユーザー以外かつログインユーザーの性別以外を表示
  # GET /members or /members.json

  # --------------------------------------------
  # 閲覧可能な全メンバー一覧を表示
  # --------------------------------------------
  def index
    # ログインユーザーがブロックしたメンバー
    @members_you_block = Decline.members_you_block(@current_user.id).map do |member|
      next member.id
    end
    # ログインユーザーをブロックしているメンバー
    @members_blocking_you = Decline.members_blocking_you(@current_user.id).map do |member|
      next member.id
    end
    # ログインユーザーがアクセスできない全メンバー
    @disable_access_members = @members_you_block + @members_blocking_you
    # 異性のmembers一覧を取得する
    @members = Member.hetero_members(@current_user, @declining_member_id_list, search_params).page(params[:page])

    if (@members.length === 0)
      raise StandardError.new "マッチする検索結果が見つかりませんでした"
    end
  rescue => error
    # error.full_message => 何故か<Encoding:ASCII-8BIT>のため､viewに表示できない
    @error_message = error.message
    return render :template => "errors/index"
  end

  # 指定した任意のmember_idの情報を表示する
  def show
    if @current_user.browsable?(params[:id]) != true
      raise StandardError.new "このメンバーを閲覧できません"
    end
    @is_yourself = false

    # 閲覧中ユーザーがログインユーザーかどうか?
    if params[:id].to_i == @current_user.id.to_i
      @is_yourself = true
      @member = Member.find params[:id]
    else
      # 自身以外のプロフィールを閲覧している場合
      # ブロックしていないかどうかをチェック
      declining = Decline.where({
        :from_member_id => @current_user.id,
        :to_member_id => params[:id],
      }).first()

      if declining != nil
        raise StandardError.new("このメンバーをブロックしています")
      end

      # ブロックされていないかどうかをチェック
      declined = Decline.where({
        :from_member_id => params[:id],
        :to_member_id => current_user.id,
      }).first()

      if declined != nil
        raise StandardError.new("このメンバーからブロックされています")
      end

      @member = Member.showable_member(@current_user, params[:id])
      # 表示可能な画像一覧のみ
      @images = @member.showable_images
    end
  rescue => error
    logger.info(error)
    return render({
             :template => "members/error",
           })
  end

  # --------------------------------------------
  # メンバーの検索条件入力フォーム
  # ここではフォームページのみを表示
  # --------------------------------------------
  def search
    # 設定ファイルデータ
    @age_list = UtilitiesController::fetch_age_list
    @gender_list = UtilitiesController::fetch_gender_list
    @languages = UtilitiesController::fetch_language_list
    @year_list = UtilitiesController::fetch_year_list
    @month_list = UtilitiesController::fetch_month_list
    @day_list = UtilitiesController::fetch_day_list
    @interested_languages = UtilitiesController::fetch_interested_language_list

    @input_params = params
    return render ({ :template => "members/search" })
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_member
    @member = Member.find(params[:id])
  end

  # メンバー検索で許可するパラメータ
  def search_params
    params.permit(
      :from_age,
      :to_age,
      :native_language,
      :gender,
      :display_name,
      :languages => [],
    )
  end

  # Only allow a list of trusted parameters through.
  def member_params
    # createメソッドで登録許可される値
    params.fetch(:member, {})
      .permit(
        :email,
        :display_name,
        :family_name,
        :given_name,
        :gender,
        :height,
        :weight,
        :birthday,
        :salary,
        :message,
        :memo,
        :password_digest
      )
  end

  # 指定したユーザーに足跡をつける
  # ただし自身のプロフィール閲覧時は､足跡を残さない
  def visited_member(member_id)

    # ログイン中ユーザーが自身のプロフィールを見た場合を除く
    if member_id.to_i == @current_user.id
      logger.info "#{@current_user.id}が自身のプロフィールページを閲覧しています｡"
      return nil
    end

    footprint = Footprint.where({
      :from_member_id => @current_user.id,
      :to_member_id => member_id,
    }).first()

    # logging
    logger.info "footprint => " + footprint.to_s

    if (footprint == nil)
      # 初めてアクセスしたとき
      footprint = Footprint.new({
        :from_member_id => @current_user.id,
        :to_member_id => member_id,
        :access_count => 1,
        :is_browsed => UtilitiesController::BINARY_TYPE[:off],
      })

      # バリデーションチェック後､足跡を保存
      if footprint.validate() == true
        footprint.save()
      end
    else
      # 二回目以降のアクセス
      # updated_atとアクセス回数のみをアップデート
      updated_at = Time.new.strftime("%Y-%m-%d %H:%M:%S") # 再訪日時
      access_count = footprint.access_count.to_i + 1 # アクセス回数
      response = footprint.update({
        :updated_at => updated_at,
        :access_count => access_count,
        :is_browsed => UtilitiesController::BINARY_TYPE[:off],
      })
    end
    # 足跡オブジェクトを返却
    return footprint
  end
end
