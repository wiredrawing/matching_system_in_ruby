class CreateLogs < ActiveRecord::Migration[6.1]
  def change
    # uuid
    # enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    create_table :logs do |t|
      t.bigint :from_member_id
      t.bigint :to_member_id
      t.integer :action_id
      t.integer :is_browsed, **{ :default => 0 }
      t.timestamps
    end

    # INDEX
    add_index :logs, [
      :from_member_id,
      :to_member_id,
    ]
  end
end
