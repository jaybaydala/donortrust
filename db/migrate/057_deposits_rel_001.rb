class DepositsRel001 < ActiveRecord::Migration
  def self.up
    create_table :deposits do |t|
      t.column :amount,               :decimal, :precision => 12, :scale => 2
      t.column :user_id,              :int
      t.column :user_hash,            :text
      t.column :credit_card,          :string, :limit => 4
      t.column :card_expiry,          :date
      t.column :authorization_result, :string
      t.column :gift_id,              :int
      t.column :created_at,           :datetime
      t.column :updated_at,           :datetime
    end
  end

  def self.down
    drop_table :deposits
  end
end
