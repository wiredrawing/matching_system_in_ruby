class CreateImages < ActiveRecord::Migration[6.1]
  def change
    create_table :images, {:id => :uuid} do |t|
      t.bigint :member_id
      t.integer :use_type
      t.string :filename
      t.integer :blur_level
      t.integer :is_approved
      # 画像閲覧用のURLトークン
      t.string :token
      # アップロード先ディレクトリを取得するためのカラム
      # /public/uploads/YYYY/mm/dd/H/M/uuid
      t.datetime :uploaded_at
      t.timestamps
    end
  end
end
