class CreateCampaignTypes < ActiveRecord::Migration
  def self.up
    create_table :campaign_types do |t|
      t.string :name
      t.boolean :has_teams
      t.timestamps
    end
    
    CampaignType.create :name => 'Seasonal', :has_teams => true
    CampaignType.create :name => 'Tradition', :has_teams => true
    CampaignType.create :name => 'School', :has_teams => true
    CampaignType.create :name => 'Registry', :has_teams => false
    
  end

  def self.down
    drop_table :campaign_types
  end
end
