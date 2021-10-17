class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Model内で URLヘルパーを使用するためモジュールのinclude
  include Rails.application.routes.url_helpers
end
