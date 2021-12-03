module Constants
  # ---------------------------------------------
  # 性別リスト
  # ---------------------------------------------
  module Gender
    List = [
      {
        :id => 0,
        :value => "未設定(required)",
        :type => :required,
      },
      {
        :id => 1,
        :value => "男性(man)",
        :type => :man,
      },
      {
        :id => 2,
        :value => "女性(woman)",
        :type => :woman,
      },
      {
        :id => 3,
        :value => "未回答(no comment)",
        :type => :nocomment,
      },
      {
        :id => 4,
        :value => "上記以外(other)",
        :type => :other,
      },
    ]

    # 定数として設定する
    TYPE = {}
    self::List.map do |gender|
      TYPE[gender[:type]] = gender[:id]
    end
  end

  # ---------------------------------------------
  # 対応言語一覧
  # ---------------------------------------------
  module Language
    List = [
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
  end

  # ---------------------------------------------
  # アップロード可能なファイル拡張子
  # ---------------------------------------------
  module Extension
    LIST = {
      "image/png" => "png",
      "image/jpeg" => "jpeg",
      "image/gif" => "gif",
      "application/pdf" => "pdf",
    }
  end

  # ---------------------------------------------
  # 有効無効フラグ
  # ---------------------------------------------
  module Binary
    Type = {
      :on => 1,
      :off => 0,
    }
  end
end
