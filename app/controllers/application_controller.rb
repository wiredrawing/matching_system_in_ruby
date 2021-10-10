class ApplicationController < ActionController::Base
  before_action :set_gender_list
  include SessionsHelper
  include RegisterHelper
  include MembersHelper
end
