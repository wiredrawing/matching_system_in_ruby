class Api::UtilitiesController < ApplicationController
  protect_from_forgery :except => [
    :get,
  ]

  # 各種ユーティリティーを返却する
  def get
    genders = UtilitiesController::GENDER_LIST
    extension_list = Constants::Extension::LIST
    # extension_list = UtilitiesController::EXTENSION_LIST
    blur_level_list = UtilitiesController::BLUR_LEVEL_LIST
    display_status_list = UtilitiesController::DISPLAY_STATUS_LIST

    response = {
      :genders => genders,
      :extenstion_list => extension_list,
      :blur_level_list => blur_level_list,
      :display_status_list => display_status_list,
    }

    return render({
             :json => response, :status => 200,
           })
  end

  def login_check
    return true
  end
end
