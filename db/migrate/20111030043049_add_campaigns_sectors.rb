class AddCampaignsSectors < ActiveRecord::Migration
  def self.up
    create_table :campaigns_sectors, :id => false do |t|
      t.column :campaign_id, :int
      t.column :sector_id, :int
    end
  end

  def self.down
    drop_table :campaigns_sectors
  end
end
