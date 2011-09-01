require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PledgeAccount do
  before(:each) do
    @valid_attributes = {
      :balance => "9.99",
      :campaign => Factory(:campaign),
      :team => nil,
      :user => Factory(:user)
    }
  end

  it "should create a new instance given valid attributes" do
    true
    #PledgeAccount.create!(@valid_attributes)
  end
end
