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
  it "should belong_to user" do
    @order.should belong_to(:user)
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
    it "should validate blank fields" do
      @order.errors.should_receive(:add_on_blank).with(%w(donor_type first_name last_name address city postal_code province country email))
      @order.validate_billing
    end
    it "should refuse a bad email address" do
      @order.email = "bademail.example.com"
      @order.should_receive(:email?).and_return(true)
      @order.validate_billing
      @order.errors.on(:email).should_not be_nil
    end
    it "should validate a good email address" do
      @order.email = "goodemail@example.com"
      @order.should_receive(:email?).and_return(true)
      @order.validate_billing
      @order.errors.on(:email).should be_nil
    end
  end

  describe "validate_payment method" do
    before do
      @order.total = 100
      @items = [mock_model(Gift, :amount => 25.0), mock_model(Deposit, :amount => 25.0), mock_model(Deposit, :amount => 50.0)]
    end
    it "should add an error to credit_card_total if it's less than the amount of the deposits" do
      @order.credit_card_total = 74.0
      @order.validate_payment(@items)
      @order.errors.on(:credit_card_total).should_not be_nil
    end
    it "should add an error to account_balance_total if it's more than the balance" do
      @order.account_balance_total = 75.0
      @order.validate_payment(@items, 74.0)
      @order.errors.on(:account_balance_total).should_not be_nil
    end
    it "should calculate the minimum_credit_card_payment to the total if no balance is passed" do
      @order.minimum_credit_card_payment(@items).should == 100
    end
    it "should calculate the minimum_credit_card_payment to just the deposits for if the balance is greater than or equal to (total - deposits)" do
      subtotal = @order.total - 75 # total - deposits
      balance = subtotal
      @order.minimum_credit_card_payment(@items, balance).should == 75 # the deposit amount
    end
    it "should calculate the minimum_credit_card_payment deposits - (total - deposits - account_balance_total) if the balance is lower than (total - deposits)" do
      @order.account_balance_total = 10
      @order.minimum_credit_card_payment(@items, 15).should == 85 # 75 + (100 - 75 - 15)
    end
    it "should add an error to base it account_balance_total + credit_card_total are less than the @order total" do
      @order.total = 100
      @order.account_balance_total = 25.0
      @order.credit_card_total = 74.0
      @order.validate_payment(@items, 25.0)
      @order.errors.on_base.should_not be_nil
    end
    it "should check the credit card fields for blank if there's a minimum credit card payment" do
      @order.stub!(:minimum_credit_card_payment).and_return(1)
      @order.errors.should_receive(:add_on_blank).with(%w(credit_card csc expiry_month expiry_year cardholder_name ))
      @order.validate_payment(@items)
    end
    it "should check the credit card fields for blank if account_balance_total is less than the total" do
      @order.total = 76
      @order.account_balance_total = 75
      @order.validate_payment(@items, 75)
      @order.errors.should_receive(:add_on_blank).with(%w(credit_card csc expiry_month expiry_year cardholder_name ))
      @order.validate_payment(@items, 100)
    end
    it "should not check the credit card fields for blank if the account_balance_total is equal to the total" do
      @order.account_balance_total = 100
      @order.validate_payment(@items, 100)
      @order.errors.should_receive(:add_on_blank).never
    end
  end
    
  describe "validate_confirmation method" do
    before do
      @items = [mock_model(Investment), mock_model(Gift), mock_model(Deposit, :amount => 25.0)]
    end
    it "should call validate_billing" do
      @order.should_receive(:validate_billing)
      @order.validate_confirmation(@items)
    end
    it "should call validate_payment" do
      @order.should_receive(:validate_payment).with(@items, nil)
      @order.validate_confirmation(@items)
    end
    it "should call validate_payment with balance, when passed" do
      @order.should_receive(:validate_payment).with(@items, 50.0)
      @order.validate_confirmation(@items, 50.0)
    end
  end
  
  describe "run_transaction method" do
    it "should run the credit_card"
    it "should return true if the credit card_processing is successful"
    it "should set the authorization_result column if the credit card_processing is successful"
    it "should return false if the credit card_processing is unsuccessful"
    it "should create a tax receipt if the credit card_processing is successful"
    it "should not create a tax receipt if the credit card_processing is unsuccessful"
  end
end