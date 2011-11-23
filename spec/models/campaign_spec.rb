require File.dirname(__FILE__) + '/../spec_helper'

describe Campaign do
  before do
    @campaign = Factory(:campaign)
  end

  it { should belong_to(:user) }
  it { should have_many(:campaign_donations) }
  it { should have_many(:participants) }
  it { should have_many(:teams) }
  it { should have_and_belong_to_many(:sectors) }

  it "should start with no teams" do
    @campaign.teams.should == []
  end

  it "should require a name" do
    @campaign.name = nil
    @campaign.valid?.should == false
  end

  it "should require a creator" do
    @campaign.user = nil
    @campaign.valid?.should == false
  end

  it "should require a url" do
    @campaign.url = nil
    @campaign.valid?.should == false
  end

  it "should have one participant when the creator is set" do
    @campaign.participants.size.should == 1
  end

  it "should have the creator as a participant" do
    @campaign.participants.first.user.should == @campaign.user
  end

  it "should start with no amount raised" do
    @campaign.amount_raised.should == 0
  end

  it "should add up the donations assigned to it" do
    @campaign.campaign_donations.create!(:amount => 100)
    @campaign.campaign_donations.create!(:amount => 150)

    @campaign.amount_raised.should == 250
  end

end