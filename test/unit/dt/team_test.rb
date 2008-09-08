require File.dirname(__FILE__) + '/../../test_helper'

context "Team" do
  
  fixtures :teams, :campaigns, :campaign_types, :users
  
  setup do
    @team_one = Team.find(1)
    @team_two = Team.find(2)
  end
  
  specify "Team should not validate when at max number of teams" do
    #setup
    @campaign = Campaign.find(1)
    
    #exercise
    @team_two.campaign = @campaign
    
    #assert
    @team_two.should.not.validate
  end
  
  specify "Should allow team creation when not at max number of teams" do
    #setup
    @campaign = Campaign.find(2)
    
    #exercise
    @team_two.campaign = @campaign
    
    #assert
    @team_two.should.validate
  end 
end