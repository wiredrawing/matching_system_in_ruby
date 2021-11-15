require_relative "boot"

require "rails/all"

# 自作ミドルウェアの読み込み
load_eager_model_filename = File.expand_path("../lib/middlewares/load_eager_model", File.dirname(__FILE__))
require load_eager_model_filename

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Bundler.require("rmagick")
Bundler.require("kaminari")

module MatchingSystem
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.time_zone = "UTC"

    # エラー時の無用なタグを制御する
    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      %Q(#{html_tag}).html_safe
    end

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/app/forms)

    # 自作ミドルウェアの読み込み
    config.middleware.use(LoadEagerModel)
  end
end
