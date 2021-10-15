class UtilitiesController < ApplicationController

  # バイナリータイプ
  BINARY_TYPE = {
    :on => 1,
    :off => 0,
  }

  # 性別リスト
  GENDER_LIST = [
    { :id => 0, :value => "未設定" },
    { :id => 1, :value => "男性" },
    { :id => 2, :value => "女性" },
    { :id => 3, :value => "上記以外" },
    { :id => 4, :value => "未回答" },
  ]
end
