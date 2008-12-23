require File.dirname(__FILE__) + '/../spec_helper'
require 'active_merchant'
ActiveMerchant::Billing::Base.mode = :test

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
  
  %w(account_balance_payment credit_card_payment total).each do |c|
    it "should strip a '$' from #{c}" do
      @order = Order.new(c.to_sym => "$50")
      @order[c].should == 50.0
    end
  end
  
  describe "balance accessors" do
    it "should save the (virtual) account_balance attribute" do
      @order.account_balance = 100
      @order.save
      @order.account_balance.should == 100
    end
    it "should save the (virtual) gift_card_balance attribute" do
      @order.gift_card_balance = 50
      @order.save
      @order.gift_card_balance.should == 50
    end
  end
  
  describe "validate_billing method" do
    before do
      @order.total = 100
      @items = [Gift.spawn(:amount => 25.0), Investment.spawn(:amount => 25.0), Deposit.spawn(:amount => 50.0)]
      @order.card_number = "4111111111111111"
      @order.cardholder_name = "Spec Name"
      @order.expiry_month = 5
      @order.expiry_year = 1.year.from_now.year.to_s
      @credit_card = mock("CreditCard", :valid? => true)
      @order.stub!(:credit_card).and_return(@credit_card)
    end
    
    it "should validate all tax receipt fields if credit_card_payment?" do
      @order.credit_card_payment = 1
      @order.errors.should_receive(:add_on_blank).with(%w(donor_type address city postal_code province country email first_name last_name))
      @order.validate_billing(@items)
    end
    it "should skip name field validation and add company if donor_type == company and credit_card_payment?" do
      @order.credit_card_payment = 1
      @order.donor_type = Order.corporate_donor
      @order.errors.should_receive(:add_on_blank).with(%w(donor_type address city postal_code province country email company))
      @order.validate_billing(@items)
    end
    it "should not validate tax receipt fields if no credit_card_payment?" do
      @order.credit_card_payment = 0
      @order.errors.should_not_receive(:add_on_blank).with(%w(donor_type first_name last_name address city postal_code province country email))
      @order.validate_billing(@items)
    end
    it "should set card_expiry to expiry_month/expiry_year" do
      @order.expiry_month = "04"
      @order.expiry_year = "2008"
      @order.card_expiry.should == '04/2008'
      @order.expiry_month.should == 4
      @order.expiry_year.should == 2008
    end

    it "should strip a credit card to the last 4 digits" do
      @order.card_number = '4111111111111234'
      @order.read_attribute(:card_number).should == "1234"
    end

    it "should return '**** **** **** 1234' when card_number_concealed" do
      @order.card_number = '4111111111111234'
      @order.card_number_concealed.should == '**** **** **** 1234'
    end
    
    it "should refuse a bad email address" do
      @order.email = "bademail.example.com"
      @order.should_receive(:email?).and_return(true)
      @order.validate_billing(@items)
      @order.errors.on(:email).should_not be_nil
    end
    it "should validate a good email address" do
      @order.email = "goodemail@example.com"
      @order.should_receive(:email?).and_return(true)
      @order.validate_billing(@items)
      @order.errors.on(:email).should be_nil
    end
  end

  describe "validate_payment method" do
    before do
      @order.total = 100
      @items = [Gift.spawn(:amount => 25.0), Investment.spawn(:amount => 25.0), Deposit.spawn(:amount => 50.0)]
    end
    
    describe "payment amount validations" do
      before do
        @items = [Gift.spawn(:amount => 25.0), Investment.spawn(:amount => 25.0), Deposit.spawn(:amount => 50.0)]
        @order.total = @items.inject(0){|sum, item| sum + item.amount }
      end
      
      it "should not add any errors" do
        @order.credit_card_payment = @order.total
        @order.validate_payment(@items)
        @order.errors.should be_empty
      end
      
      describe "without a gift_card_balance or account_balance" do
        it "should add an error if you're not paying the full amount" do
          @order.credit_card_payment = @order.total - 0.01
          @order.validate_payment(@items)
          @order.errors.on_base.include?("Please ensure you're paying the full amount.").should be_true
        end
        it "should add an error if you're trying to pay more than the full amount" do
          @order.credit_card_payment = @order.total + 0.01
          @order.validate_payment(@items)
          @order.errors.on_base.should_not be_nil
          @order.errors.on_base.include?("You only need to pay the cart total.").should be_true
        end
        it "should not error if you're trying to pay the total" do
          @order.credit_card_payment = @order.total
          @order.validate_payment(@items)
          @order.errors.should be_empty
        end
      end

      describe "with a gift_card_balance and no account_balance" do
        before do
          @order.gift_card_balance = 100
        end
        it "should add an error if you're not paying the full amount" do
          @order.gift_card_payment = @order.total - 0.01
          @order.validate_payment(@items)
          @order.errors.on_base.include?("Please ensure you're paying the full amount.").should be_true
        end
        it "should add an error if you're paying more than the full amount" do
          @order.gift_card_payment = @order.total
          @order.credit_card_payment = 0.01
          @order.validate_payment(@items)
          @order.errors.on_base.include?("You only need to pay the cart total.").should be_true
        end
        it "should not error if you're trying to pay the total" do
          @order.gift_card_payment = @order.total
          @order.validate_payment(@items)
          @order.errors.should be_empty
        end
        it "should add an error to gift_card_payment if you try to pay more than the gift_card_balance" do
          @order.gift_card_balance = @order.total - 1
          @order.gift_card_payment = @order.total
          @order.validate_payment(@items)
          @order.errors.on(:gift_card_payment).should_not be_nil
        end
      end
      
      describe "with no gift_card_balance and an account_balance" do
        before do
          @order.account_balance = 100
          # we'll remove the deposit from the items so we don't have issues
          @items = [Gift.spawn(:amount => 25.0), Investment.spawn(:amount => 25.0), Investment.spawn(:amount => 50.0)]
        end
        it "should add an error if you're not paying the full amount" do
          @order.account_balance_payment = @order.total - 0.01
          @order.validate_payment(@items)
          @order.errors.on_base.include?("Please ensure you're paying the full amount.").should be_true
        end
        it "should add an error if you're paying more than the full amount" do
          @order.account_balance_payment = @order.total
          @order.credit_card_payment = 0.01
          @order.validate_payment(@items)
          @order.errors.on_base.include?("You only need to pay the cart total.").should be_true
        end
        it "should not error if you're trying to pay the total" do
          @order.account_balance_payment = @order.total
          @order.validate_payment(@items)
          @order.errors.should be_empty
        end
        it "should add an error to account_balance_payment if you try to pay more than the account_balance" do
          @order.account_balance = @order.total - 1
          @order.account_balance_payment = @order.total
          @order.validate_payment(@items)
          @order.errors.on(:account_balance_payment).should_not be_nil
        end
      end
      
      describe "with a gift_card_balance and account_balance" do
        before do
          @order.gift_card_balance = 100
          @order.account_balance = 100
        end
        it "should add an error if you're not paying the full amount" do
          @order.gift_card_payment = @order.total/2
          @order.account_balance_payment = @order.total/2 - 0.01
          @order.validate_payment(@items)
          @order.errors.on_base.include?("Please ensure you're paying the full amount.").should be_true
        end
        it "should add an error if you're paying more than the full amount" do
          @order.gift_card_payment = @order.total/2
          @order.account_balance_payment = @order.total/2 + 0.01
          @order.validate_payment(@items)
          @order.errors.on_base.include?("You only need to pay the cart total.").should be_true
        end
        it "should not error if you're trying to pay the total" do
          @order.gift_card_payment = @order.total/2
          @order.account_balance_payment = @order.total/2
          @order.validate_payment(@items)
          @order.errors.should be_empty
        end
        it "should add a error if you're paying less than the deposit on your gift_card" do
          @order.account_balance_payment = @order.total - deposit_total + 0.01
          @order.gift_card_payment = deposit_total - 0.01
          @order.validate_payment(@items)
          @order.errors.on_base.include?("You must pay at least #{number_to_currency(deposit_total)} from a credit card and/or gift card.").should be_true
        end
        it "should add a error if you're paying less than the deposit on your credit_card" do
          @order.account_balance_payment = @order.total - deposit_total + 0.01
          @order.credit_card_payment = deposit_total - 0.01
          @order.validate_payment(@items)
          @order.errors.on_base.include?("You must pay at least #{number_to_currency(deposit_total)} from a credit card and/or gift card.").should be_true
        end
        it "should add a error if you're paying less than the deposit on your credit_card and gift_card combined" do
          @order.account_balance_payment = @order.total - deposit_total + 0.01
          @order.gift_card_payment = deposit_total/2
          @order.credit_card_payment = deposit_total/2 - 0.01
          @order.validate_payment(@items)
          @order.errors.on_base.include?("You must pay at least #{number_to_currency(deposit_total)} from a credit card and/or gift card.").should be_true
        end
        def deposit_total
          total = @items.inject(0){|sum, deposit| sum + (deposit.class == Deposit ? deposit.amount : 0) }
        end
      end
    end
    
    describe "checking credit card validity" do
      before do
        @credit_card = mock("CreditCard", :valid? => true)
        @order.stub!(:credit_card).and_return(@credit_card)
        @order.credit_card_payment = 1
      end
      it "should check the credit card for validity if there's a minimum credit card payment" do
        @order.stub!(:minimum_credit_card_payment).and_return(1)
        @credit_card.should_receive(:valid?).and_return(true)
        @order.validate_billing(@items)
      end
      it "should check the credit card for validity if account_balance_payment is less than the total" do
        @order.total = 76
        @order.account_balance_payment = 75
        @credit_card.should_receive(:valid?).and_return(true)
        @order.account_balance = 100
        @order.validate_billing(@items)
      end
      it "should check the credit card for validity if there's a credit_card_payment" do
        @order.credit_card_payment = 1
        @credit_card.should_receive(:valid?).and_return(true)
        @order.account_balance = 100
        @order.validate_billing(@items)
      end
    end
    describe "invalid credit card" do
      before do
        @credit_card = mock("CreditCard", :valid? => false)
        @errors = mock("Errors", :full_messages => ["error1", "error2"])
        @order.stub!(:minimum_credit_card_payment).and_return(1)
        @order.card_number = "4111111111111111"
        @order.cvv = "035"
        @order.expiry_month = "04"
        @order.expiry_year = 1.year.from_now.year.to_s
        @order.cardholder_name = "Spec User"
        @order.credit_card_payment = 1
      end
      it "should add errors to the order if the credit card is invalid" do
        @order.stub!(:credit_card).and_return(@credit_card)
        @credit_card.stub!(:errors).and_return(@errors)
        @credit_card.should_receive(:valid?).and_return(false)
        @credit_card.should_receive(:errors).and_return(@errors)
        @order.errors.should_receive(:add_to_base).at_least(:once)
        @order.account_balance = 100
        @order.validate_billing(@items)
      end
      it "should add errors to the order if the cvv is blank" do
        @order.cvv = ""
        @order.account_balance = 100
        @order.validate_billing(@items)
        @order.credit_card.errors.on(:verification_value).should_not be_blank
      end
      it "should add errors to the order if the cardholder_name is blank" do
        @order.cardholder_name = ""
        @order.account_balance = 100
        @order.validate_billing(@items)
        @order.credit_card.errors.on(:cardholder_name).should_not be_blank
      end
      it "should add errors to the order if the card_number is blank" do
        @order.card_number = ""
        @order.account_balance = 100
        @order.validate_billing(@items)
        @order.credit_card.errors.on(:number).should_not be_blank
      end
    end
    it "should not check the credit card for validity if the account_balance_payment is equal to the total" do
      @order.account_balance_payment = 100
      @order.account_balance = 100
      @order.validate_billing(@items)
      @order.should_receive(:generate_credit_card).never
      @order.errors.should_receive(:add_on_blank).never
    end
  end
    
  describe "validate_confirmation method" do
    before do
      @order.card_number = "4111111111111111"
      @order.cardholder_name = "Spec Name"
      @order.expiry_month = 5
      @order.expiry_year = 1.year.from_now.year
      @items = [Gift.spawn(:amount => 25.0), Investment.spawn(:amount => 25.0), Deposit.spawn(:amount => 50.0)]
      # @items = [mock_model(Investment), mock_model(Gift), mock_model(Deposit, :amount => 25.0)]
    end
    it "should call validate_billing" do
      @order.should_receive(:validate_billing)
      @order.validate_confirmation(@items)
    end
    it "should call validate_payment" do
      @order.should_receive(:validate_payment).with(@items)
      @order.validate_confirmation(@items)
    end
    it "should call validate_payment with balance, when passed" do
      @order.account_balance = 50
      @order.validate_payment(@items)
      @order.should_receive(:validate_payment).with(@items)
      @order.account_balance = 50
      @order.validate_confirmation(@items)
    end
  end
  
  describe "credit_card method" do
    before do
      @order.card_number = "4111111111111111"
      @order.cvv = "989"
      @order.expiry_month = "04"
      @order.expiry_year = 1.year.from_now.year.to_s
      @order.cardholder_name = "Cardholder Name"
    end
    it "should set ActiveMerchant::Billing::CreditCard.canadian_currency to true" do
      @order.credit_card
      ActiveMerchant::Billing::CreditCard.canadian_currency?.should be_true
    end
    it "should return a CreditCard object" do
      @order.credit_card.should be_instance_of(ActiveMerchant::Billing::CreditCard)
    end
    it "should be valid" do
      @order.credit_card.valid?.should be_true
    end
    {"card_number"=>"number", "cvv"=>"verification_value", "expiry_month"=>"month", "expiry_year"=>"year", "cardholder_name"=>"cardholder_name"}.each do |column, cc_column|
      it "should not be valid without a #{column}" do
        @order.send!("#{column}=", nil)
        @order.credit_card.valid?.should be_false
        @order.credit_card.errors[cc_column].should_not be_nil
      end
    end
  end
  
  describe "run_transaction method" do
    before do
      @credit_card = ActiveMerchant::Billing::CreditCard.new(
        :number          => "4111111111111111",
        :month           => "05",
        :year            => "2028",
        :cardholder_name => "Joe Smith",
        :verification_value  => "989"
      )
      @credit_card.stub!(:valid?).and_return(true)
      @order.stub!(:credit_card).and_return(@credit_card)
      
      @order.country = "Canada"
      @order.order_number = 8118118118
      @order.total = 1.0
    end

    # *	Dollar Amount $1.00 OK: 678594;
    # *	Dollar Amount $2.00 REJ: 15;
    # *	Dollar Amount $3.00 OK: 678594;
    # *	Dollar Amount $4.00 REJ: 15;
    # *	Dollar Amount $5.00 REJ: 15;
    # *	Dollar Amount $6.00 OK: 678594:X;
    # *	Dollar Amount $7.00 OK: 678594:y;
    # *	Dollar Amount $8.00 OK: 678594:A;
    # *	Dollar Amount $9.00 OK: 678594:Z;
    # *	Dollar Amount $10.00 OK: 678594:N;
    # *	Dollar Amount $15.00, if CVV2=1234 OK: 678594:Y; if there is no CVV2: REJ: 19
    # *	Dollar Amount $16.00 REJ: 2;
    # *	Other Amount REJ: 15.
    
    it "should get a credit_card object" do
      @order.should_receive(:credit_card).any_number_of_times.and_return(@credit_card)
      @order.run_transaction
    end
    it "should set the authorization_result column if the credit card_processing is successful" do
      @order.total = 1
      @order.should_receive(:update_attributes).with({:authorization_result => "678594:"}).and_return(true)
      @order.run_transaction
    end
    it "should create a tax receipt if the credit card_processing is successful" do
      @order.total = 1
      @order.country = "Canada"
      @order.should_receive(:create_tax_receipt_from_order)
      @order.run_transaction
    end
    it "should create a tax receipt if the credit card_processing is successful and country isn't Canada" do
      @order.total = 1
      @order.country = "Somewhere Else"
      @order.should_receive(:create_tax_receipt_from_order).never
      @order.run_transaction
    end
    it "should not set the authorization_result column if the credit card_processing is unsuccessful" do
      @order.should_receive(:update_attributes).never
      lambda {
        @order.total = 2
        @order.run_transaction
      }
    end
    it "should not create a tax receipt if the credit card_processing is unsuccessful" do
      @order.should_receive(:create_tax_receipt_from_order).never
      lambda {
        @order.total = 2
        @order.country = "Canada"
        @order.run_transaction
      }
    end
    
    it "should return true when successful" do
      @order.total = 1
      @order.run_transaction.should be_true
    end
    it "should raise a ActiveMerchant::Billing::Error when passed an invalid credit_card" do
      @credit_card.should_receive(:valid?).and_return(false)
      lambda { 
        @order.run_transaction 
      }.should raise_error(ActiveMerchant::Billing::Error)
    end
    %w(2 4 5 16 100).each do |amount|
      it "should raise a ActiveMerchant::Billing::Error when not successful ($#{amount.to_i}.00)" do
        @order.total = amount.to_i
        lambda { 
          @order.run_transaction
        }.should raise_error(ActiveMerchant::Billing::Error)
      end
    end
    {"1" => "678594:", "3" => "678594:", "6" => "678594:X", "7" => "678594:Y", "8" => "678594:A", "9" => "678594:Z", "10" => "678594:N"}.each do |amount, auth_result|
      it "should set the correct authorization_result for successful amounts ($#{amount}.00)" do
        @order.total = amount.to_i
        @order.run_transaction
        @order.authorization_result.should == auth_result
      end
    end
    # 15.00, if CVV2=1234 OK: 678594:Y; if there is no CVV2: REJ: 19
    it "should set the correct authorization_result with a correct cvv" do
      @order.total = 15
      @credit_card.verification_value = "1234"
      @order.run_transaction
      @order.authorization_result.should == "678594:Y"
    end
    it "should raise an error with an incorrect cvv" do
      @order.total = 15
      @credit_card.verification_value = "9876"
      lambda { 
        @order.run_transaction
      }.should raise_error(ActiveMerchant::Billing::Error)
    end
    it "should raise an error with a blank cvv" do
      @order.total = 15
      @credit_card.verification_value = nil
      lambda { 
        @order.run_transaction
      }.should raise_error(ActiveMerchant::Billing::Error)
    end
  end
  
  describe "create_order_with_investment_from_project_gift method" do
    before do
      @gift = Gift.generate!(:project => Project.generate!)
    end
    it "should do nothing for a gift card" do
      @gift.project = nil
      @gift.save
      lambda{ Order.create_order_with_investment_from_project_gift(@gift) }.should_not change(Order, :count)
    end
    it "should create an order from a project gift" do
      lambda{ Order.create_order_with_investment_from_project_gift(@gift) }.should change(Order, :count).by(1)
    end
    it "should have the required gift information" do
      first_name, last_name = @gift.to_name.to_s.split(/ /, 2)
      order = Order.create_order_with_investment_from_project_gift(@gift)
      order.first_name.should == first_name
      order.last_name.should == last_name
      order.email.should == @gift.to_email
      order.total.should == @gift.amount
      order.gift_card_payment.should == @gift.amount
      order.gift_card_payment_id.should == @gift.id
    end
    it "should create an investment associated with the new order" do
      order = Order.create_order_with_investment_from_project_gift(@gift)
      order.investments.size.should == 1
    end
    it "should have an investment with the gift information" do
      order = Order.create_order_with_investment_from_project_gift(@gift)
      i = order.investments[0]
      i.gift_id.should == @gift.id
      i.amount.should == @gift.amount
      i.project.should == @gift.project
    end
  end
end