require File.dirname(__FILE__) + '/../spec_helper'

describe Campaign do
  before do
    @valid_attributes = Factory.build(:campaign).attributes    
  end
  
  it "should create a new instance given valid attributes" do
    Campaign.create!(@valid_attributes)
  end
  
  
end