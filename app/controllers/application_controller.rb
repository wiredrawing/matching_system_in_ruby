class ApplicationController < ActionController::Base
  Hirb.enable()
  # helperの読み込み
  include SessionsHelper
  include RegisterHelper
  include MembersHelper
  include Api::ImagesHelper
  include Api::TimelineHelper

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
    @genders = Constants::Gender::List.map do |gender|
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
    @languages = Constants::Language::List.map do |lang|
      next [
             lang[:value],
             lang[:id],
           ]
    end
    return @languages
  end

  # ---------------------------------------------
  # ログインユーザーへの通知一覧を取得する
  # ---------------------------------------------
  def uncheck_notices
    @uncheck_notices = nil
    if defined?(request.session[:member_id]) == nil
      return false
    end

    # 未確認の通知情報を取得する
    @uncheck_notices = Log.where({
      :to_member_id => request.session[:member_id],
    }).where.not({
      :is_browsed => Constants::Binary::Type[:on],
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
          :is_browsed => Constants::Binary::Type[:on],
        }).or(Timeline.where({
          :is_browsed => nil,
        }))
      )
      return true
    end
  end

  # ---------------------------------------------
  # 未確認の足跡を取得する
  # ---------------------------------------------
  def uncheck_footprints
    @uncheck_footprints = nil

    if defined?(request.session[:member_id]) == nil
      return false
    else
      @uncheck_footprints = Footprint.where({
        :to_member_id => request.session[:member_id],
      }).and(
        Footprint.where.not({
          :is_browsed => Constants::Binary::Type[:on],
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
    if self.logged_in? == true && self.current_user.token_for_api != nil
      return true
    end
    session[:member_id] = nil
    # 未ログイン時は､ログインフォームへ
    return(redirect_to(login_url))
  end
end
