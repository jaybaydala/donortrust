require File.dirname(__FILE__) + '/../../test_helper'

context "Campaign" do
  
  fixtures :teams, :campaigns, :campaign_types, :users
  
  setup do
    @team = Team.find(:first)
    @team.leader = User.find(:first)
  end
  
  specify "Should not allow creation when at max number of teams" do
    #setup
    @campaign = Campaign.find_first
    @campaign.max_number_of_teams = 1
  end
end