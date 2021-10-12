class CreateUrls < ActiveRecord::Migration[6.1]
  def change
    create_table :urls do |t|

      t.bigint :member_id
      t.string :url
      t.timestamps
    end
  end
end
