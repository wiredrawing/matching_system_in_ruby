class ApplicationController < ActionController::Base
  before_action :set_gender_list
  before_action :logged_in?
  include SessionsHelper
  include RegisterHelper
  include MembersHelper
end
