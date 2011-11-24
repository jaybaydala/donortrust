require File.dirname(__FILE__) + '/../spec_helper'

describe Cart do
  before do
    @cart = Cart.create!(:add_optional_donation => false)
    @gift = mock_model(Gift, :attributes => Factory.build(:gift).attributes, :valid? => true)
    @deposit = mock_model(Deposit, :attributes => Factory.build(:deposit).attributes, :valid? => true)
    @investment = mock_model(Investment, :attributes => Factory.build(:investment).attributes, :valid? => true)
  end
  
  it "should start empty" do
    @cart.items.should == []
  end
  
  it "should start with a total of 0.0" do
    @cart.total.should == 0.0
  end
  
  describe "total" do
    it "should return the total of all the items" do
      @gift.attributes[:amount] = 100
      @investment.attributes[:amount] = 25
      @deposit.attributes[:amount] = 15
      @cart.add_item @gift
      @cart.add_item @investment
      @cart.add_item @deposit
      @cart.total.should == 140.0
    end
  end

  context "when the cart belongs to an order (is in the checkout process)" do
    let(:investment) { Factory.build(:investment, :amount => 10) }
    let(:order) { Factory(:order, { :total => 0 }) }
    subject { order.cart }
    specify { order.total.should == 0 }
    context "and an item is added to the cart" do
      before do
        item = subject.add_item(investment)
        order.reload
      end
      specify { order.total.should == investment.amount }
      context "and subsequently removed" do
        before do
          subject.empty!
          order.reload
        end
        specify { order.reload.total.should == 0 }
      end
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
      @cart.items.last.item.class.should == Gift
    end
    it "should allow Investment items" do
      @cart.add_item @investment
      @cart.items.last.item.class.should == Investment
    end
    it "should allow Deposit items" do
      @cart.add_item @deposit
      @cart.items.last.item.class.should == Deposit
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
      @cart_line_items = mock_model(CartLineItem)
      @items = [
        Factory(:cart_line_item, :item => @gift), 
        Factory(:cart_line_item, :item => @investment), 
        Factory(:cart_line_item, :item => @deposit)
      ]
      @cart_line_items.stub(:find).with(@items[0].id).and_return(@items[0])
      @cart_line_items.stub(:find).with(@items[1].id).and_return(@items[1])
      @cart_line_items.stub(:find).with(@items[2].id).and_return(@items[2])
      @cart.stub!(:items).and_return(@cart_line_items)
    end
    it "should not allow an invalid item" do
      @gift.should_receive(:valid?).and_return(false)
      before_items = @cart.items.clone
      @cart.update_item(@items[0].id, @gift)
      @cart.items.should == before_items
    end
    
    it "should allow a valid item" do
      @gift.should_receive(:valid?).and_return(true)
      @cart.update_item(@items[0].id, @gift)
      @cart.items.find(@items[0].id).item.attributes.should == @gift.attributes
    end
    
    it "should allow Gift items" do
      @cart.update_item(@items[0].id, @gift)
      @cart.items.find(@items[0].id).item.attributes.should == @gift.attributes
    end
    it "should allow Investment items" do
      @cart.update_item(@items[1].id, @investment)
      @cart.items.find(@items[1].id).item.attributes.should == @investment.attributes
    end
    it "should allow Deposit items" do
      @cart.update_item(@items[2].id, @deposit)
      @cart.items.find(@items[2].id).item.attributes.should == @deposit.attributes
    end
    it "should not allow Project items" do
      @project = mock_model(Project)
      @project.stub!(:valid?).and_return(true)
      @cart.update_item(@items[0].id, @project)
      @cart.items.find(@items[0].id).item.attributes.should == @gift.attributes
    end
  end
  
  describe "remove_item" do
    before do
      @cart.add_item @gift
      @cart.add_item @investment
      @cart.add_item @deposit
    end

    # by item array index?
    it "should remove an item by cart_line_item id" do
      @cart.remove_item(@cart.items.second.id)
      @cart.items.reload.size.should == 2
      @cart.items.first.item.class.should == Gift
      @cart.items.second.item.class.should == Deposit
    end
  end
  
  describe "minimum_credit_card_payment" do
    before do
      @deposit1 = mock_model(Deposit, :amount => 50.0, :attributes => Factory.build(:deposit).attributes, :valid? => true)
      @deposit2 = mock_model(Deposit, :amount => 60.0, :attributes => Factory.build(:deposit).attributes, :valid? => true)
      @deposit1.attributes[:amount] = 50
      @deposit2.attributes[:amount] = 60
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

  describe "calculate_percentage_amount" do
    subject { Cart.create!(:add_optional_donation => true) }
    let(:cart) { subject }
    before do
      Factory(:admin_project)
      cart.add_item(Factory.build(:gift, :amount => 100))
    end

    it "should have two line items" do
      cart.items.size.should == 2
    end

    its(:total) { should eql(115) }
  end

  describe "calculate_percentage_amount_upowered_item" do
    subject { Cart.create!(:add_optional_donation => true) }
    let(:cart) { subject }
    before do
      Factory(:admin_project)
      user = Factory(:user)
      cart.add_item(Factory.build(:gift, :amount => 100))
      cart.add_upowered(20, user)
      cart.reload
    end

    it "should have three line items" do
      cart.items.size.should == 3
    end

    it "should calculate the tip on everything except the upowered entry" do
      cart.total.should eql(135)
    end
  end
end
