require File.dirname(__FILE__) + '/../spec_helper'

describe TeamMembership do
  it { should belong_to(:user) }
  it { should belong_to(:team) }

  describe "team_association_rules" do
    before do
      @user = Factory(:user)
      @campaign1 = Factory(:campaign)
      @campaign2 = Factory(:campaign)
      user1 = Factory(:user)
      user2 = Factory(:user)
      user3 = Factory(:user)
      Participant.create!(:user => @user, :campaign => @campaign1)
      Participant.create!(:user => @user, :campaign => @campaign2)
      Participant.create!(:user => user1, :campaign => @campaign1)
      Participant.create!(:user => user1, :campaign => @campaign2)
      Participant.create!(:user => user2, :campaign => @campaign1)
      Participant.create!(:user => user3, :campaign => @campaign1)

      @team1 = Team.create!(:campaign => @campaign1, :user => user1, :name => "team 1", :goal => 50.00)
      @team2 = Team.create!(:campaign => @campaign1, :user => user2, :name => "team 2", :goal => 60.00)
      @other_campaign_team = Team.create!(:campaign => @campaign2, :user => user1, :name => "team 3", :goal => 500.00)
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

    it "should require a user to be a participant in the campaign before joining the team" do
      Participant.delete_all
      membership = TeamMembership.new(:user => @user, :team => @team1)
      membership.valid?.should == false
      participant = Participant.create!(:user => @user, :campaign => @campaign1)
      membership.valid?.should == true
    end

  end
end