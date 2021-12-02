class ApplicationRecord < ActiveRecord::Base

  # # 有効な登録済みメンバー一覧を返却する
  # before_action :registered_members

  self.abstract_class = true

  # # Model内でURLヘルパー関数を使用できるようにする
  # Rails.application.routes.default_url_options[:host] = "localhost:3000"

  # Model内で URLヘルパーを使用するためモジュールのinclude
  include Rails.application.routes.url_helpers

  private

  # --------------------------------------
  # 登録済みメンバー情報を取得
  # --------------------------------------
  def registered_members
    @registered_members = Member.where({
      :is_registered => Constants::Binary::Type[:on],
    }).map do |member|
      next member.id
    end
    return @registered_members
  end
end
