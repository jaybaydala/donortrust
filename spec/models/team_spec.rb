require File.dirname(__FILE__) + '/../spec_helper'

describe Team do
  before do
    @user = Factory.create(:user)
    @campaign = Factory.create(:campaign, :user => @user)
    @team = Factory.create(:team, :user => @user, :campaign => @campaign)
  end

  it { should belong_to(:user) }
  it { should have_many(:team_memberships) }

  it "should validate_presence_of name" do
    @team.should validate_presence_of(:name)
  end

  it "should validate_numericality_of name" do
    @team.should validate_numericality_of(:goal)
  end

  it "should only allow goals greater than 0" do
    @team.goal = -20.00
    @team.valid?.should eql false
    @team.goal = 20.00
    @team.valid?.should eql true
  end

  it "should start with the team creator as a member" do
    @team.team_memberships.size.should == 1
    @team.team_memberships.first.user.should == @team.user
  end

end