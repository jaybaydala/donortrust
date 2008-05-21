require File.dirname(__FILE__) + '/../spec_helper'

describe Cart do
  before do
    @cart = Cart.new
    @gift = mock_model(Gift)
    @deposit = mock_model(Deposit)
    @investment = mock_model(Investment)
    @gift.stub!(:valid?).and_return(true)
    @deposit.stub!(:valid?).and_return(true)
    @investment.stub!(:valid?).and_return(true)
  end
  
  it "should start with an empty items array" do
    @cart.items.should == []
  end
  
  it "should start with a total of 0.0" do
    @cart.total.should == 0.0
  end
  
  describe "total" do
    it "should return the total of all the items" do
      @gift.should_receive(:amount).and_return(100)
      @investment.should_receive(:amount).and_return(25)
      @deposit.should_receive(:amount).and_return(15)
      @cart.add_item @gift
      @cart.add_item @investment
      @cart.add_item @deposit
      @cart.total.should == 140.0
    end
  end
  
  describe "add_item" do
    it "should not allow an invalid item" do
      @gift.should_receive(:valid?).and_return(false)
      @cart.add_item @gift
      @cart.items.should be_empty
    end
    
    it "should not allow a invalid item" do
      @gift.should_receive(:valid?).and_return(true)
      @cart.add_item @gift
      @cart.items.should_not be_empty
    end
    
    it "should allow Gift items" do
      @cart.add_item @gift
      @cart.items.last.class.should == Gift
    end
    it "should allow Investment items" do
      @cart.add_item @investment
      @cart.items.last.class.should == Investment
    end
    it "should allow Deposit items" do
      @cart.add_item @deposit
      @cart.items.last.class.should == Deposit
    end
    it "should not allow Project items" do
      @project = mock_model(Project)
      @project.stub!(:valid?).and_return(true)
      @cart.add_item @project
      @cart.items.should be_empty
    end
  end
  
  describe "remove_item" do
    before do
      @cart.add_item @gift
      @cart.add_item @investment
      @cart.add_item @deposit
    end

    # by item array index?
    it "should remove an item by array index" do
      @cart.remove_item(1)
      @cart.items.size.should == 2
      @cart.items[0].class.should == Gift
      @cart.items[1].class.should == Deposit
    end
  end
  
  it "should be empty?" do
    @cart.empty?.should == true
  end
  
  it "should not be empty? after an item is added" do
    @cart.add_item @gift
    @cart.empty?.should == false
  end
end
