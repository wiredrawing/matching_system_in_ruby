class CreateFootprints < ActiveRecord::Migration[6.1]
  def change
    create_table :footprints do |t|

      t.bigint :from_member_id
      t.bigint :to_member_id
      t.bigint :access_count
      t.integer :is_browsed # 足跡のチェックフラグ
      t.timestamps
    end
  end
end
