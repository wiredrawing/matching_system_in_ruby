class CreateDeclines < ActiveRecord::Migration[6.1]
  def change
    create_table :declines do |t|

      t.bigint :from_member_id
      t.bigint :to_member_id

      t.timestamps
    end
  end
end
