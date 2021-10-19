class CreateTimelines < ActiveRecord::Migration[6.1]
  def change
    create_table :timelines do |t|
      t.bigint :from_member_id
      t.bigint :to_member_id
      t.integer :timeline_type
      t.integer :message_id
      t.integer :url_id
      t.integer :image_id
      t.integer :is_browsed
      t.timestamps
    end

    # INDEXの追加
    add_index :timelines, [
      :from_member_id,
      :to_member_id,
    ]
  end
end
