class AddCampaignProjectLinkingTable < ActiveRecord::Migration
  def self.up
    create_table :campaigns_projects, {:id => false} do |t|
      t.integer :campaign_id
      t.integer :project_id
    end
  end

  def self.down
    drop_table :campaigns_projects
  end
end
