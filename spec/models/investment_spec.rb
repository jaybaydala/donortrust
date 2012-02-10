require File.dirname(__FILE__) + '/../spec_helper'

describe Investment do
  before do
  end

  let(:user) { Factory(:user) }
  let(:project) { Factory(:project) }
  let(:investment) { Factory(:investment, :project => project) }

  context "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:project) }
    it { should belong_to(:group) }
    it { should belong_to(:gift) }
    it { should belong_to(:order) }
    it { should belong_to(:promotion) }
    it { should belong_to(:campaign) }
    it { should have_one(:user_transaction) }
  end

  context "validations" do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount) }
    it { should validate_numericality_of(:project_id) }
    it { should validate_presence_of(:project_id) }
  end

  describe "after create" do
    it "should create project poi" do
      lambda do
        user.investments.create! :amount => 1, :project => project
      end.should change(ProjectPoi, :count).by(1)
      ProjectPoi.last.user.should == user
      ProjectPoi.last.project.should == project
      ProjectPoi.last.investor.should == true
    end

    it "should reuse project_pois" do
      # note no user set in this project_poi, investment should find it by email and set user
      Factory(:project_poi, :email => user.email, :project => project, :investor => false)
      lambda do
        user.investments.create! :amount => 1, :project => project
      end.should change(ProjectPoi, :count).by(0)
      ProjectPoi.last.user.should == user
      ProjectPoi.last.project.should == project
      ProjectPoi.last.investor.should == true
    end
  end
end
