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

  # アップロード可能なファイル拡張子
  EXTENSION_LIST = {
    "image/png" => "png",
    "image/jpeg" => "jpeg",
    "image/gif" => "gif",
    "application/pdf" => "pdf",
  }

  BLUR_LEVEL = [
    ["ぼかさない", 0],
    ["小", 5],
    ["中", 15],
    ["大", 30],
  ]

  BLUR_LEVEL_LIST = [
    {
      :id => 0,
      :value => "ぼかさない",
    },
    {
      :id => 5,
      :value => "小",
    },
    {
      :id => 15,
      :value => "中",
    },
    {
      :id => 30,
      :value => "大",
    },
  ]

  # ユーザーのアクションリスト
  ACTION_ID_LIST = {
    :like => 10, # 特定のメンバーからいいねをもらった場合
    :match => 20, # 任意のメンバーとマッチングした場合
    :message => 30, # マッチングしたメンバーからのメッセージ受信
    :notice => 40, # システム側からのメッセージ通知があった場合
  }
  ACTION_STRING_LIST = [
    10 => "いいねがきました",
    20 => "マッチングしました",
    30 => "メッセージがきました",
    40 => "システムメッセージがきました",
  ]

  # 画像の表示ステータス
  DISPLAY_STATUS_LIST = [
    {
      :id => 1,
      :value => "表示中",
    },
    {
      :id => 0,
      :value => "非表示",
    },
  ]

  #
  def self.gender_id_list
    gender_id_list = self::GENDER_LIST.map do |gender|
      next gender[:id]
    end
    return gender_id_list
  end
end
