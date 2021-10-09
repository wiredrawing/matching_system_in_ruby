class CreateLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :logs do |t|

      t.bigint :from_member_id
      t.bigint :to_member_id
      t.integer :action_id
      t.integer :is_browsed
      t.timestamps
    end
  end
end
