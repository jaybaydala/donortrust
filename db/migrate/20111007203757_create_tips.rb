class CreateTips < ActiveRecord::Migration
  def self.up
    create_table :tips do |t|
      t.decimal :amount, :precision => 12, :scale => 2
      t.integer :user_id
      t.integer :project_id
      t.integer :group_id
      t.integer :gift_id
      t.string :user_ip_addr
      t.integer :order_id
      t.integer :promotion_id
      t.integer :campaign_id
      t.timestamps
    end
  end

  def self.down
    drop_table :tips
  end
end
