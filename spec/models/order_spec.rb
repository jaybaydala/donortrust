require File.dirname(__FILE__) + '/../spec_helper'

describe Order do
  before do
    @order = Order.new(:email => "user@example.com")
  end
  
  it "should initialize with donor_type == 'personal'" do
    @order.donor_type.should == Order.personal_donor
  end

  it "should have_many gifts" do
    @order.should have_many(:gifts)
  end
  it "should have_many investments" do
    @order.should have_many(:investments)
  end
  it "should have_many deposits" do
    @order.should have_many(:deposits)
  end
  
  %w(account_balance_total credit_card_total total).each do |c|
    it "should strip a '$' from #{c}" do
      @order = Order.new(c.to_sym => "$50")
      @order[c].should == 50.0
    end
  end
  
  it "should set card_expiry to expiry_month/expiry_year" do
    @order.expiry_month = "04"
    @order.expiry_year = "2008"
    @order.card_expiry.should == '04/2008'
  end
  
  it "should strip a credit card to the last 4 digits before save" do
    @order.credit_card = '4111111111111234'
    @order.save
    @order.credit_card.should == "1234"
  end
  
  it "should return '**** **** **** 1234' when credit_card_concealed" do
    @order.credit_card = '4111111111111234'
    @order.credit_card_concealed.should == '**** **** **** 1234'
  end
  
  describe "validate_billing method" do
    
  end

  describe "validate_payment method" do
    
  end
    
  describe "validate_confirmation method" do
    
  end
end