# モデルファイルとマイグレーションファイルを同時作成する
# 以下コマンドを実行する
# rails g model Language
class CreateLanguages < ActiveRecord::Migration[6.1]
  def change
    create_table :languages, id: :uuid do |t|
      t.bigint :member_id
      t.integer :language
      t.timestamps
    end
  end
end
