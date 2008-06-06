class CreateCampaignTypes < ActiveRecord::Migration
  def self.up
    create_table :campaign_types do |t|
      t.string :name
      t.timestamps
    end
    
    CampaignType.create :name => 'Seasonal'
    CampaignType.create :name => 'Tradition'
    CampaignType.create :name => 'School'
    CampaignType.create :name => 'Registry'
    
  end

  def self.down
    drop_table :campaign_types
  end
end
