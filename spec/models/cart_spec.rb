require File.dirname(__FILE__) + '/../spec_helper'

describe Cart do
  before do
    @cart = Cart.new
  end
  
  it "should contain items" do
    @cart.items.should == []
  end
  
  it "should have a total" do
    @cart.total.should == 0.0
  end
  
  describe "total" do
    it "should return the total of all the items" do
      @cart.add_item Gift.new(:amount => 100)
      @cart.add_item Investment.new(:amount => 25)
      @cart.add_item Deposit.new(:amount => 15)
      @cart.total.should == 140.0
    end
  end
  
  describe "items" do
    it "should allow Gift items" do
      @cart.add_item Gift.new
      @cart.items.last.class.should == Gift
    end
    it "should allow Investment items" do
      @cart.add_item Investment.new
      @cart.items.last.class.should == Investment
    end
    it "should allow Deposit items" do
      @cart.add_item Deposit.new
      @cart.items.last.class.should == Deposit
    end
    it "should not allow Project items" do
      @cart.add_item Project.new
      @cart.items.last.class.should_not == Project
    end
  end
  
  it "should be empty?" do
    @cart.empty?.should == true
  end
  
  it "should not be empty? after an item is added" do
    @cart.add_item Gift.new
    @cart.empty?.should == false
  end
end
