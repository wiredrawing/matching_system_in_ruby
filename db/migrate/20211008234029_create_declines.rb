class CreateDeclines < ActiveRecord::Migration[6.1]
  def change
    # uuidを使うため
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    create_table :declines, **{ :id => :uuid } do |t|
      t.bigint :from_member_id
      t.bigint :to_member_id
      t.timestamps
    end
  end
end
