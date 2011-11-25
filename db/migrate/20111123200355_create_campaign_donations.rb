class CreateCampaignDonations < ActiveRecord::Migration
  def self.up
    create_table :campaign_donations do |t|
      t.integer :campaign_id
      t.decimal :amount, :precision => 12, :scale => 2
      t.integer :user_id
      t.integer :participant_id
      t.string :user_ip_addr
      t.integer :order_id

      t.timestamps
    end
  end

  def self.down
    drop_table :campaign_donations
  end
end
