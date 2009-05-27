class AddCampaignToInvestments < ActiveRecord::Migration
  def self.up
    add_column :investments, :campaign_id, :integer
  end

  def self.down
    remove_column :investments, :campaign_id
  end
end
