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
    
    it "should allow a valid item" do
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
  
  describe "update_item" do
    before do
      @cart.stub!(:items).and_return([@gift, @investment, @deposit])
    end
    it "should not allow an invalid item" do
      @gift.should_receive(:valid?).and_return(false)
      before_items = @cart.items.clone
      @cart.update_item(0, @gift)
      @cart.items.should == before_items
    end
    
    it "should allow a valid item" do
      @gift.should_receive(:valid?).and_return(true)
      @cart.update_item(0, @gift)
      @cart.items[0].should == @gift
    end
    
    it "should allow Gift items" do
      @cart.update_item(0, @gift)
      @cart.items[0].should == @gift
    end
    it "should allow Investment items" do
      @cart.update_item(1, @investment)
      @cart.items[1].should == @investment
    end
    it "should allow Deposit items" do
      @cart.update_item(2, @deposit)
      @cart.items[2].should == @deposit
    end
    it "should not allow Project items" do
      @project = mock_model(Project)
      @project.stub!(:valid?).and_return(true)
      @cart.update_item(0, @project)
      @cart.items[0].should == @gift
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
  
  describe "minimum_credit_card_payment" do
    before do
      @deposit1 = mock_model(Deposit, :amount => 50.0, :valid? => true)
      @deposit2 = mock_model(Deposit, :amount => 60.0, :valid? => true)
      @cart.add_item(@deposit1)
      @cart.add_item(@deposit2)
      @cart.add_item(@gift)
      @cart.add_item(@investment)
    end
    
    it "should return the sum of all deposits" do
      @cart.minimum_credit_card_payment.should == @deposit1.amount + @deposit2.amount
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
