class CreateImages < ActiveRecord::Migration[6.1]
  def change
    # uuidを使うため
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    create_table :images, { :id => :uuid } do |t|
      t.bigint :member_id
      t.integer :use_type
      t.string :filename
      t.string :extension
      t.integer :blur_level
      # 画像の承認状態
      t.integer :is_approved, **{ :default => 0 }
      # 表示状態
      t.integer :is_displayed, **{ :default => 0 }
      # 削除状態
      t.integer :is_deleted, **{ :default => 0 }
      # 画像閲覧用のURLトークン
      t.string :token
      # アップロード先ディレクトリを取得するためのカラム
      # /public/uploads/YYYY/mm/dd/H/M/uuid
      t.datetime :uploaded_at
      t.timestamps
    end
  end
end
