class CreateMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :members do |t|
      t.string :email, {
        :null => false,
      }
      t.string :display_name
      t.string :family_name
      t.string :given_name
      t.integer :gender
      t.integer :height
      t.integer :weight
      t.date :birthday
      t.integer :salary
      t.text :message
      t.text :memo
      t.string :token
      t.string :password_digest
      # 本登録完了の場合 => 1
      t.integer :is_registered, {
        :limit => 2,
        :null => false,
        :default => 0,
      }
      t.timestamps
    end
  end
end
