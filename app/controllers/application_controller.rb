class ApplicationController < ActionController::Base
  # helperの読み込み
  include SessionsHelper
  include RegisterHelper
  include MembersHelper
  include Api::ImagesHelper
  include Api::TimelineHelper
  # before_action :set_gender_list
  before_action :login_check
  before_action :uncheck_notices
  before_action :uncheck_messages
  before_action :uncheck_footprints
  before_action :genders
  before_action :languages

  private

  # ---------------------------------------------
  # 性別リスト一覧を取得する
  # ---------------------------------------------
  def genders
    @genders = UtilitiesController::GENDER_LIST.map do |gender|
      next [
             gender[:value],
             gender[:id],
           ]
    end
    return @genders
  end

  # ---------------------------------------------
  # 言語リスト一覧を取得する
  # ---------------------------------------------
  def languages
    @languages = UtilitiesController::LANGUAGE_LIST.map do |lang|
      next [
             lang[:value],
             lang[:id],
           ]
    end
    return @languages
  end

  # ログインユーザーへの通知一覧を取得する
  def uncheck_notices
    @uncheck_notices = nil
    if defined?(request.session[:member_id]) == nil
      return false
    end

    # 未確認の通知情報を取得する
    @uncheck_notices = Log.where({
      :to_member_id => request.session[:member_id],
    }).where.not({
      :is_browsed => UtilitiesController::BINARY_TYPE[:on],
    })
    return true
  end

  # ---------------------------------------------
  # 未確認のメッセージを取得する
  # ---------------------------------------------
  def uncheck_messages
    @uncheck_messages = nil
    if defined?(request.session[:member_id]) == nil
      return false
    else
      @uncheck_messages = Timeline.where({
        :to_member_id => request.session[:member_id],
      }).and(
        Timeline.where.not({
          :is_browsed => UtilitiesController::BINARY_TYPE[:on],
        }).or(Timeline.where({
          :is_browsed => nil,
        }))
      )
      return true
    end
  end

  def uncheck_footprints
    @uncheck_footprints = nil

    if defined?(request.session[:member_id]) == nil
      return false
    else
      @uncheck_footprints = Footprint.where({
        :to_member_id => request.session[:member_id],
      }).and(
        Footprint.where.not({
          :is_browsed => UtilitiesController::BINARY_TYPE[:on],
        }).or(Footprint.where({
          :is_browsed => nil,
        }))
      )
      return true
    end
  end

  # ---------------------------------------------
  # 未ログインの場合は､ログインページへリダイレクト
  # ---------------------------------------------
  def login_check
    # sessions_helperのメソッドを読み込む
    if self.logged_in? == true
      return true
    end
    # 未ログイン時は､ログインフォームへ
    return(redirect_to(login_url))
  end
end
