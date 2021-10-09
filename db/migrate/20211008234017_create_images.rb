class CreateImages < ActiveRecord::Migration[6.1]
  def change
    create_table :images do |t|

      t.bigint :member_id
      t.integer :use_type
      t.string :filename, {
        :limit => 512
      }
      t.integer :blur_level
      t.integer :is_approved
      # 画像閲覧用のURLトークン
      t.string :token, {
        :limit => 512
      }
      t.timestamps
    end
  end
end
