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
    }.to change { Team.count }.by(1)
  end
  
  describe "closing a completed campaign" do
    before do
      @allocations_user = Factory(:user)
      User.stub(:allocations_user).and_return(@allocations_user)
      @projects = (1..3).map{ Factory(:project) }
      @campaign = Factory(:campaign, :allow_multiple_teams => false)
      @campaign.projects = @projects
      @pledge_order = Factory(:order, :complete => true, :total => @campaign.fundraising_goal)
      @pledge_order.pledges.create!(:team => @campaign.default_team, :amount => @campaign.fundraising_goal, :pledger => Faker::Name.name, :pledger_email => Faker::Internet.email, :admin_user => @campaign.creator, :paid => true)
    end
    
    it "should mark funds_allocated as true" do
      do_close
      @campaign.funds_allocated.should be_true
    end
    it "should create a new PledgeAccount" do
      expect { do_close }.to change { PledgeAccount.count }.by(1)
    end
    it "should put the raised funds into the pledge account" do
      do_close
      @campaign.pledge_account.balance.should == @campaign.funds_raised
    end
    it "should create a new Cart" do
      expect { do_close }.to change { Cart.count }.by(1)
    end
    it "should create a new Order" do
      expect { do_close }.to change { Order.count }.by(1)
    end
    it "should associate the Order with the campaign creator" do
      do_close
      @order.user.should == @campaign.creator
    end
    it "should create at least one Investment" do
      expect { do_close }.to change { Investment.count }
    end
    it "should associate the Investments with the campaign creator" do
      do_close
      @order.investments.each{|i| i.user.should == @campaign.creator }
    end
    it "should split the amount evenly between available projects" do
      do_close
      funds_left = @campaign.reload.funds_raised
      max_per_project = (@campaign.reload.funds_raised/@campaign.projects.count).round(2)
      project_investments ||= {}
      # spread the funds out in the projects - this accounts for forgotten pennies
      while funds_left > 0
        @campaign.projects.each do |p|
          project_investments[p.id] ||= 0
          investment_amount = max_per_project < funds_left ? max_per_project : funds_left
          project_investments[p.id] += investment_amount
          funds_left -= investment_amount
        end
      end
      project_investments.each do |project_id, amount|  
        @order.investments.find_by_project_id(project_id).amount.should == amount
      end
    end
    it "should use the total amount in the Investments" do
      do_close
      @order.total.should == @campaign.funds_raised
      @order.total.should == @order.investments.inject(0){|sum, i| sum + i.amount }
    end
    
    context "if a project is fully funded" do
      before do
        @full_project = @projects.first
        @full_project.stub(:current_need).and_return(0)
      end
  
      it "shouldn't add an Investment to that project" do
        do_close
        Investment.find_by_project_id(@full_project).should be_nil
      end
    end
    
    context "if only some of the funds can be applied to projects" do
      before do
        @projects.each{|p| p.stub(:current_need).and_return(200) }
        @leftover_balance = 1000 - (@projects.count * 200)
      end
      it "should Deposit the remaining money into the Allocations user account" do
        expect { do_close }.to change { Deposit.count }.by(1)
      end
      it "puts all the remaining balance in the deposit" do
        do_close
        @order.deposits.first.amount.should == @leftover_balance
      end
      it "deposits the extra to the allocations user account" do
        do_close
        @order.deposits.first.user.should == @allocations_user
      end
    end
    
    context "if all projects are fully funded" do
      before do
        @projects.each{|p| p.stub(:current_need).and_return(0) }
      end
      it "should Deposit the entire amount into the Allocations user account" do
        do_close
        @order.deposits.first.user.should == @allocations_user
        @order.deposits.first.amount.should == @campaign.funds_raised
      end
    end
    
    def do_close
      @order = @campaign.close!
    end
  end
end