class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.bigint :from_member_id
      t.bigint :to_member_id
      t.integer :favorite
      t.timestamps
    end
  end
end
