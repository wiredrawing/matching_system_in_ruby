class UtilitiesController < ApplicationController

  # バイナリータイプ
  BINARY_TYPE = {
    :on => 1,
    :off => 0,
  }

  # 性別リスト
  GENDER_LIST = [
    { :id => 0, :value => "未設定(required)" },
    { :id => 1, :value => "男性(guy)" },
    { :id => 2, :value => "女性(woman)" },
    { :id => 3, :value => "未回答(no comment)" },
    { :id => 4, :value => "上記以外(other)" },
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
    { :id => 0, :value => "ぼかさない" },
    { :id => 10, :value => "小" },
    { :id => 15, :value => "中" },
    { :id => 30, :value => "大" },
  ]

  # 画像アップロードの種別
  USE_TYPE_LIST = {
    :none => 0,
    :profile => 1,
    :timeline => 2,
  }
  USE_TYPE_NAME_LIST = {
    0 => "未設定",
    1 => "プロフィール",
    2 => "タイムライン",
  }

  # ユーザーのアクションリスト
  ACTION_ID_LIST = {
    :like => 10, # 特定のメンバーからいいねをもらった場合
    :match => 20, # 任意のメンバーとマッチングした場合
    :message => 30, # マッチングしたメンバーからのメッセージ受信
    :notice => 40, # システム側からのメッセージ通知があった場合
  }

  ACTION_STRING_LIST = {
    10 => "からいいねがきました",
    20 => "とマッチングしました",
    30 => "からメッセージがきました",
    40 => "システムメッセージがきました",
  }

  # 画像の表示ステータス
  DISPLAY_STATUS_LIST = [
    { :id => 1, :value => "表示中" },
    { :id => 0, :value => "非表示" },
  ]

  # アップロード可能なファイルサイズ
  # 5MBに制御
  UPLOADABLE_SIZE = 3000000

  # 母国語リスト
  LANGUAGE_LIST = [
    { :id => 0, :value => "未設定" },
    { :id => 1, :value => "日本語" },
    { :id => 2, :value => "英語" },
    { :id => 3, :value => "韓国語" },
    { :id => 4, :value => "スウェーデン語" },
    { :id => 5, :value => "スペイン語" },
    { :id => 6, :value => "タイ語" },
    { :id => 7, :value => "ドイツ語" },
    { :id => 8, :value => "フィリピン語" },
    { :id => 9, :value => "フランス語" },
    { :id => 10, :value => "ロシア語" },
    { :id => 11, :value => "中国語" },
    { :id => 12, :value => "イタリア語" },
    { :id => 13, :value => "インドネシア語" },
    { :id => 14, :value => "インド語" },
    { :id => 1000, :value => "その他" },
  ]

  INTERESTED_LANGUAGE_LIST = LANGUAGE_LIST.select do |lang|
    if lang[:id] > 0
      next true
    end
    next false
  end

  # 年齢リスト
  AGE_LIST = (0..100).map do |age|
    if age == 0
      next { :id => age, :value => "未設定" }
    end
    next { :id => age, :value => age.to_s + "歳" }
  end

  # 西暦リスト
  YEAR_LIST = (1900..(Time.new.strftime("%Y").to_i)).map do |year|
    next { :id => year, :value => year.to_s + "年" }
  end

  # 月リスト
  MONTH_LIST = (1..12).map do |month|
    next { :id => month, :value => month.to_s + "月" }
  end

  # 日リスト
  DAY_LIST = (1..30).map do |day|
    next { :id => day, :value => day.to_s + "日" }
  end

  def self.fetch_age_list
    list = self::AGE_LIST.map do |d|
      next [d[:value], d[:id]]
    end
    return list
  end

  def self.fetch_gender_list
    list = self::GENDER_LIST.map do |d|
      next [d[:value], d[:id]]
    end
    return list
  end

  def self.fetch_language_list
    list = self::LANGUAGE_LIST.map do |d|
      next [d[:value], d[:id]]
    end
    return list
  end

  def self.fetch_interested_language_list
    p self::INTERESTED_LANGUAGE_LIST
    list = self::INTERESTED_LANGUAGE_LIST.map do |d|
      next [d[:value], d[:id]]
    end
    return list
  end

  def self.fetch_year_list
    list = self::YEAR_LIST.map do |d|
      next [d[:value], d[:id]]
    end
    return list
  end

  def self.fetch_month_list
    list = self::MONTH_LIST.map do |d|
      next [d[:value], d[:id]]
    end
    return list
  end

  def self.fetch_day_list
    list = self::DAY_LIST.map do |d|
      next [d[:value], d[:id]]
    end
    return list
  end

  def self.gender_id_list
    gender_id_list = self::GENDER_LIST.map do |gender|
      next gender[:id]
    end
    return gender_id_list
  end
end
