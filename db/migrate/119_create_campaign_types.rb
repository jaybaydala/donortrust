class CreateCampaignTypes < ActiveRecord::Migration
  def self.up
    create_table :campaign_types do |t|
      t.string :name
      t.boolean :has_teams
      t.timestamps
    end
    
    CampaignType.create :name => 'Seasonal', :has_teams => true
    CampaignType.create :name => 'Traditional', :has_teams => true
    CampaignType.create :name => 'School', :has_teams => true
    CampaignType.create :name => 'Registry', :has_teams => false
    
    # Campaign.create :name => 'Test Campaign',
    #                 :email => 'test@cfoo.com',
    #                 :short_name => 'testcampaign',
    #                 :description => 'description!',
    #                 :user_id => 1,
    #                 :campaign_type_id => 2,
    #                 :pending => 0,
    #                 :fundraising_goal => 10000,
    #                 :goal_currency => 'CDN',
    #                 :fee_amount => 10,
    #                 :fee_currency => 'CDN',
    #                 :start_date => '2008-06-05 19:59:44',
    #                 :end_date => '2009-06-05 19:59:44',
    #                 :address => '3838 Elbow Drive SW',
    #                 :city => 'Calgary',
    #                 :province => 'AB',
    #                 :country => 'Canada',
    #                 :postalcode => 'T2S2J8',
    #                 :require_team_authorization => 1,
    #                 :allow_multiple_teams => 1,
    #                 :max_number_of_teams => 5,
    #                 :max_size_of_teams => 10,
    #                 :max_participants => 50
    
  end

  def self.down
    drop_table :campaign_types
  end
end
