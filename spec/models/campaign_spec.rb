require File.dirname(__FILE__) + '/../spec_helper'

describe Campaign do
  before do
    @valid_attributes = Factory.build(:campaign).attributes
  end
  
  it "should create a new instance given valid attributes" do
    Campaign.create!(@valid_attributes)
  end
  
  it "should create a default team if multiple teams are not allowed" do
    expect {
      Factory(:campaign, :allow_multiple_teams => false)
    }.to change { Team.count }
  end
  
  describe "closing a completed campaign" do
    before do
      @campaign = Factory(:campaign, :allow_multiple_teams => false)
      @order = Factory(:order, :complete => true, :total => @campaign.fundraising_goal)
      @order.pledges.create!(:order => @order, :campaign => @campaign, :team => @campaign.default_team, :amount => @campaign.fundraising_goal, :pledger => Faker::Name.name, :pledger_email => Faker::Internet.email)
    end
    
    it "should create a new Order" do
      expect { do_close }.to change { Order.count }.by(1)
    end
    it "should create at least one Investment" do
      expect { do_close }.to change { Investment.count }
    end
    it "should associate the Order and Investments with the campaign creator" do
      do_close
      @order.user.should == @campaign.creator
      @order.investments.each{|i| i.user.should == @campaign.creator }
    end
    it "should split the amount evenly between available projects"
    
    context "if a project if fully funded" do
      it "shouldn't add an Investment to that project"
    end
    
    context "if all projects are fully funded" do
      it "should Deposit the money into the Allocations user account"
    end
    
    def do_close
      @campaign.close
    end
  end
end