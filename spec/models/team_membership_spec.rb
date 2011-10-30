require File.dirname(__FILE__) + '/../spec_helper'

describe TeamMembership do
  before do
    @team_member = Factory(:team_membership)
  end

  it { should belong_to(:user) }
  it { should belong_to(:team) }

  describe "team_association_rules" do
    before do
      @user = Factory(:user)
      @campaign1 = Factory(:campaign)
      @campaign2 = Factory(:campaign)
      @team1 = Factory(:team, :campaign => @campaign1)
      @team2 = Factory(:team, :campaign => @campaign1)
      @other_campaign_team = Factory(:team, :campaign => @campaign2)
    end

    it "should not allow a user to join two teams for the same campaign" do
      membership1 = TeamMembership.new(:user => @user, :team => @team1)
      membership1.save
      membership2 = TeamMembership.new(:user => @user, :team => @team2)
      membership2.user.teams.reload
      membership2.valid?.should == false
    end

    it "should allow a user to join multiple teams in different campaigns" do
      membership1 = TeamMembership.new(:user => @user, :team => @team1)
      membership1.save
      membership2 = TeamMembership.new(:user => @user, :team => @other_campaign_team)
      membership2.user.teams.reload
      membership2.valid?.should == true
    end
  end

end