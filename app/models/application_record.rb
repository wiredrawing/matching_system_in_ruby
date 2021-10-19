class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # # Model内でURLヘルパー関数を使用できるようにする
  # Rails.application.routes.default_url_options[:host] = "localhost:3000"

  # Model内で URLヘルパーを使用するためモジュールのinclude
  include Rails.application.routes.url_helpers
end
