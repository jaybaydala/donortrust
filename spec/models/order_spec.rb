require File.dirname(__FILE__) + '/../spec_helper'
require 'active_merchant'
ActiveMerchant::Billing::Base.mode = :test

describe Order do
  let(:cart_items) { [Factory.build(:gift, :amount => 25.0), Factory.build(:investment, :amount => 25.0), Factory.build(:deposit, :amount => 50.0)] }
  let(:order) { Factory(:order, { :email => "user@example.com", :credit_card_payment => nil, :total => nil }) }
  let(:cart) { order.cart }

  before do
    cart_items.each {|item| cart.add_item(item) }
    order.reload
  end

  it "should create an order properly with default values" do
    Order.create! Factory.build(:order).attributes
  end
  
  it "should initialize with donor_type == 'personal'" do
    order.donor_type.should == Order.personal_donor
  end

  it { should belong_to(:user) }
  it { should have_many(:gifts) }
  it { should have_many(:gifts) }
  it { should have_many(:gifts) }
  
  context "stripping '$' from amounts" do
    %w(account_balance_payment credit_card_payment total).each do |c|
      it "should strip a '$' from #{c}" do
        order = Order.new(c.to_sym => "$50")
        order[c].should == 50.0
      end
    end
  end
  
  describe "balance accessors" do
    it "should save the (virtual) account_balance attribute" do
      order.account_balance = 100
      order.save
      order.account_balance.should == 100
    end
    it "should save the (virtual) gift_card_balance attribute" do
      order.gift_card_balance = 50
      order.save
      order.gift_card_balance.should == 50
    end
  end

  context "adding and removing cart items" do
    let(:investment) { Factory.build(:investment, :amount => 10) }
    before do
      # load the cart, change the value and reload it. This is due to an BelongsToAssociation weirdness
      Cart.find(order.cart_id).update_attribute(:add_optional_donation, false)
      cart.reload
    end

    it "should increase the total when a cart item is added" do
      expect do
        cart.add_item(investment)
      end.to change {order.reload.total}.by(10)
    end

    it "should increase the credit_card_payment when a cart item is added" do
      expect do
        cart.add_item(investment)
      end.to change {order.reload.credit_card_payment}.by(10)
    end

    it "should decrease the total when a cart item is removed" do
      item = cart.add_item(investment)
      order.reload
      expect do
        cart.remove_item(item.id)
      end.to change {order.reload.total}.by(-10)
    end

    it "should decrease the credit_card_payment when a cart item is removed" do
      item = cart.add_item(investment)
      order.reload
      expect do
        cart.remove_item(item.id)
      end.to change {order.reload.credit_card_payment}.by(-10)
    end
  end

  describe "#billing_info_required? validations" do
    context "when billing_info_required?" do
      before do
        subject.stub!(:billing_info_required?).and_return(true)
      end
      %w(donor_type address city postal_code province country email first_name last_name).each do |attribute|
        it { should validate_presence_of(attribute)}
      end
    end

    context "when billing_info_required? and the corporate donor_type" do
      before do
        subject.stub!(:billing_info_required?).and_return(true)
        subject.donor_type = Order.corporate_donor
      end
      it { should validate_presence_of(:company) }
      it { should_not validate_presence_of(:first_name) }
      it { should_not validate_presence_of(:last_name) }
    end

    context "when no tax_receipt_requested?" do
      before do
        subject.tax_receipt_requested = false
      end
      %w(donor_type address city postal_code province country first_name last_name).each do |attribute|
        it { should_not validate_presence_of(attribute) }
      end
    end

    it "should refuse a bad email address" do
      order.email = "bademail.example.com"
      order.valid?
      order.errors.on(:email).should_not be_nil
    end
    it "should validate a good email address" do
      order.email = "goodemail@example.com"
      order.valid?
      order.errors.on(:email).should be_nil
    end
  end

  describe "validate_credit_card method" do
    before do
      order.card_number = "4111111111111111"
      order.cardholder_name = "Spec Name"
      order.expiry_month = 5
      order.expiry_year = 1.year.from_now.year.to_s
      @credit_card = mock("CreditCard", :valid? => true)
      order.stub!(:credit_card).and_return(@credit_card)
    end
    
    it "should set card_expiry to expiry_month/expiry_year" do
      order.expiry_month = "04"
      order.expiry_year = "2008"
      order.card_expiry.should == '04/2008'
      order.expiry_month.should == 4
      order.expiry_year.should == 2008
    end

    it "should strip a credit card to the last 4 digits" do
      order.card_number = '4111111111111234'
      order.read_attribute(:card_number).should == "1234"
    end

    it "should return '**** **** **** 1234' when card_number_concealed" do
      order.card_number = '4111111111111234'
      order.card_number_concealed.should == '**** **** **** 1234'
    end
  end

  describe "#validate_payment" do
    context "payment amount validations" do
      it "should not add any errors" do
        order.validate_payment
        order.errors.should be_empty
      end
      
      context "when we don't have a gift_card_balance or account_balance" do
        it "should add an error if you're not paying the full amount" do
          order.credit_card_payment = order.total - 0.01
          order.validate_payment
          order.errors.on_base.include?("Please ensure you're paying the full amount.").should be_true
        end
        it "should add an error if you're trying to pay more than the full amount" do
          order.credit_card_payment = order.total + 0.01
          order.validate_payment
          order.errors.on_base.should_not be_nil
          order.errors.on_base.include?("You only need to pay the cart total.").should be_true
        end
        it "should not error if you're trying to pay the total" do
          order.credit_card_payment = order.total
          order.validate_payment
          order.errors.should be_empty
        end
      end

      context "when we have a gift_card_balance and no account_balance" do
        before do
          order.credit_card_payment = 0
          order.gift_card_balance = order.total
        end
        it "should add an error if you're not paying the full amount" do
          order.gift_card_payment = order.total - 0.01
          order.validate_payment
          order.errors.on_base.include?("Please ensure you're paying the full amount.").should be_true
        end
        it "should add an error if you're paying more than the full amount" do
          order.gift_card_payment = order.total
          order.credit_card_payment = 0.01
          order.validate_payment
          order.errors.on_base.include?("You only need to pay the cart total.").should be_true
        end
        it "should not error if you're trying to pay the total" do
          order.gift_card_payment = order.total
          order.validate_payment
          order.errors.should be_empty
        end
        it "should add an error to gift_card_payment if you try to pay more than the gift_card_balance" do
          order.gift_card_balance = order.total - 1
          order.gift_card_payment = order.total
          order.validate_payment
          order.errors.on(:gift_card_payment).should_not be_nil
        end
      end
      
      context "when we have no gift_card_balance and an account_balance" do
        # we'll remove the deposit from the items so we don't have issues
        let(:cart_items) { [Factory.build(:gift, :amount => 25.0), Factory.build(:investment, :amount => 25.0), Factory.build(:investment, :amount => 50.0)] }
        before do
          order.account_balance = BigDecimal.new("100")
          cart.empty!
          cart.reload
          cart_items.each {|item| cart.add_item(item) }
          order.reload
          order.credit_card_payment = 0
        end
        it "should add an error if you're not paying the full amount" do
          order.account_balance_payment = order.total - 0.01
          order.validate_payment
          order.errors.on_base.include?("Please ensure you're paying the full amount.").should be_true
        end
        it "should add an error if you're paying more than the full amount" do
          order.account_balance_payment = order.total
          order.credit_card_payment = 0.01
          order.validate_payment
          order.errors.on_base.include?("You only need to pay the cart total.").should be_true
        end
        it "should not error if you're trying to pay the total" do
          order.account_balance_payment = order.total
          order.validate_payment
          order.errors.should be_empty
        end
        it "should add an error to account_balance_payment if you try to pay more than the account_balance" do
          order.account_balance = order.total - 1
          order.account_balance_payment = order.total
          order.validate_payment
          order.errors.on(:account_balance_payment).should_not be_nil
        end
      end
      
      context "with a gift_card_balance and account_balance" do
        before do
          order.credit_card_payment = 0
          order.gift_card_balance = 100
          order.account_balance = 100
        end
        it "should add an error if you're not paying the full amount" do
          order.gift_card_payment = order.total/2
          order.account_balance_payment = order.total/2 - 0.01
          order.validate_payment
          order.errors.on_base.include?("Please ensure you're paying the full amount.").should be_true
        end
        it "should add an error if you're paying more than the full amount" do
          order.gift_card_payment = order.total/2
          order.account_balance_payment = order.total/2 + 0.01
          order.validate_payment
          order.errors.on_base.include?("You only need to pay the cart total.").should be_true
        end
        it "should not error if you're trying to pay the total" do
          order.gift_card_payment = order.total/2
          order.account_balance_payment = order.total/2
          order.validate_payment
          order.errors.should be_empty
        end
        it "should add a error if you're paying less than the deposit on your gift_card" do
          order.account_balance_payment = order.total - deposit_total + 0.01
          order.gift_card_payment = deposit_total - 0.01
          order.validate_payment
          order.errors.on_base.include?("You must pay at least #{number_to_currency(deposit_total)} from a credit card and/or gift card.").should be_true
        end
        it "should add a error if you're paying less than the deposit on your credit_card" do
          order.account_balance_payment = order.total - deposit_total + 0.01
          order.credit_card_payment = deposit_total - 0.01
          order.validate_payment
          order.errors.on_base.include?("You must pay at least #{number_to_currency(deposit_total)} from a credit card and/or gift card.").should be_true
        end
        it "should add a error if you're paying less than the deposit on your credit_card and gift_card combined" do
          order.account_balance_payment = order.total - deposit_total + 0.01
          order.gift_card_payment = deposit_total/2
          order.credit_card_payment = deposit_total/2 - 0.01
          order.validate_payment
          order.errors.on_base.include?("You must pay at least #{number_to_currency(deposit_total)} from a credit card and/or gift card.").should be_true
        end
        def deposit_total
          total = cart_items.inject(0){|sum, deposit| sum + (deposit.class == Deposit ? deposit.amount : 0) }
        end
      end
      
      context "with an offline_fund_payment and no credit_card" do
        let(:user) { Factory(:user) }
        before do 
          user.stub(:cf_admin?).and_return(true)
          order.user = user
          order.credit_card_payment = 0
          order.offline_fund_payment = order.total
        end
        
        it "should validate_payment" do
          order.validate_payment
          order.errors.should be_empty
        end

        it "should still validate_payment even if there's an account balance" do
          order.account_balance = 100
          order.validate_payment
          order.errors.should be_empty
        end

        context "with no user" do
          before do
            order.user = nil
          end
          
          it "should automatically set the offline_fund_payment to nil" do
            order.offline_fund_payment = order.total
            order.offline_fund_payment.should be_nil
          end
        end

        context "with a non-admin user" do
          before do
            user.stub(:cf_admin?).and_return(false)
          end
          
          it "should automatically set the offline_fund_payment to nil" do
            order.offline_fund_payment = order.total
            order.offline_fund_payment.should be_nil
          end
        end
      end
    end
    
    context "checking credit card validity" do
      before do
        @credit_card = mock("CreditCard", :valid? => true)
        order.stub!(:credit_card).and_return(@credit_card)
        order.credit_card_payment = 1
      end
      it "should check the credit card for validity if there's a minimum credit card payment" do
        order.stub!(:minimum_credit_card_payment).and_return(1)
        @credit_card.should_receive(:valid?).and_return(true)
        order.validate_credit_card
      end
      it "should check the credit card for validity if account_balance_payment is less than the total" do
        order.total = 76
        order.account_balance_payment = 75
        @credit_card.should_receive(:valid?).and_return(true)
        order.account_balance = 100
        order.validate_credit_card
      end
      it "should check the credit card for validity if there's a credit_card_payment" do
        order.credit_card_payment = 1
        @credit_card.should_receive(:valid?).and_return(true)
        order.account_balance = 100
        order.validate_credit_card
      end
    end
    context "invalid credit card" do
      before do
        @credit_card = mock("CreditCard", :valid? => false)
        @errors = mock("Errors", :full_messages => ["error1", "error2"])
        order.stub!(:minimum_credit_card_payment).and_return(1)
        order.card_number = "4111111111111111"
        order.cvv = "035"
        order.expiry_month = "04"
        order.expiry_year = 1.year.from_now.year.to_s
        order.cardholder_name = "Spec User"
        order.credit_card_payment = 1
      end
      it "should add errors to the order if the credit card is invalid" do
        order.stub!(:credit_card).and_return(@credit_card)
        @credit_card.stub!(:errors).and_return(@errors)
        @credit_card.should_receive(:valid?).and_return(false)
        @credit_card.should_receive(:errors).and_return(@errors)
        order.errors.should_receive(:add_to_base).at_least(:once)
        order.account_balance = 100
        order.validate_credit_card
      end
      it "should add errors to the order if the cvv is blank" do
        order.cvv = ""
        order.account_balance = 100
        order.validate_credit_card
        order.credit_card.errors.on(:verification_value).should_not be_blank
      end
      # it "should add errors to the order if the cardholder_name is blank" do
      #   order.cardholder_name = ""
      #   order.account_balance = 100
      #   order.validate_credit_card
      #   order.credit_card.errors.on(:cardholder_name).should_not be_blank
      # end
      it "should add errors to the order if the card_number is blank" do
        order.card_number = ""
        order.account_balance = 100
        order.validate_credit_card
        order.credit_card.errors.on(:number).should_not be_blank
      end
    end
    it "should not check the credit card for validity if the account_balance_payment is equal to the total" do
      order.account_balance_payment = 100
      order.account_balance = 100
      order.validate_credit_card
      order.should_receive(:generate_credit_card).never
      order.errors.should_receive(:add_on_blank).never
    end
  end
    
  describe "#validate_confirmation" do
    before do
      order.card_number = "4111111111111111"
      order.cardholder_name = "Spec Name"
      order.expiry_month = 5
      order.expiry_year = 1.year.from_now.year
    end
    it "should call validate_credit_card" do
      order.should_receive(:validate_credit_card)
      order.validate_confirmation
    end
    it "should call validate_payment" do
      order.should_receive(:validate_payment)
      order.validate_confirmation
    end
    it "should call validate_payment with balance, when passed" do
      order.account_balance = 50
      order.validate_payment
      order.should_receive(:validate_payment)
      order.account_balance = 50
      order.validate_confirmation
    end
  end
  
  describe "#credit_card" do
    before do
      order.card_number = "4111111111111111"
      order.cvv = "989"
      order.expiry_month = "04"
      order.expiry_year = 1.year.from_now.year.to_s
      order.cardholder_name = "Cardholder Name"
    end
    # it "should set ActiveMerchant::Billing::CreditCard.canadian_currency to true" do
    #   order.credit_card
    #   ActiveMerchant::Billing::CreditCard.canadian_currency?.should be_true
    # end
    it "should return a CreditCard object" do
      order.credit_card.should be_instance_of(ActiveMerchant::Billing::CreditCard)
    end
    it "should be valid" do
      order.credit_card.valid?.should be_true
    end
    context "invalid credit cards" do
      {"card_number"=>"number", "cvv"=>"verification_value", "expiry_month"=>"month", "expiry_year"=>"year"}.each do |column, cc_column|
        it "should not be valid without a #{column}" do
          order.send("#{column}=", nil)
          order.credit_card.valid?.should be_false
          order.credit_card.errors[cc_column].should_not be_nil
        end
      end
    end
  end

  describe "#valid_transaction?" do
    specify { order.should_receive(:validate_payment); order.valid_transaction? }
    specify { order.should_receive(:validate_credit_card); order.valid_transaction? }
  end

  describe "#run_transaction" do
    before do
      @credit_card = ActiveMerchant::Billing::CreditCard.new(
        :number          => "4111111111111111",
        :month           => "05",
        :year            => "2028",
        :first_name      => "Joe",
        :last_name       => "Smith",
        :verification_value  => "989"
      )
      # @credit_card.stub!(:valid?).and_return(true)
      order.stub!(:credit_card).and_return(@credit_card)
      order.stub(:valid_transaction?).and_return(true)
      
      order.country = "Canada"
      order.order_number = 8118118118
      order.total = 1.0
      order.credit_card_payment = order.total
      order.remote_ip = '123.123.123.123'
    end

    # *	Dollar Amount $1.00 OK: 678594;
    # *	Dollar Amount $2.00 REJ: 15;
    # *	Dollar Amount $3.00 OK: 678594;
    # *	Dollar Amount $4.00 REJ: 15;
    # *	Dollar Amount $5.00 REJ: 15;
    # *	Dollar Amount $6.00 OK: 678594:;
    # *	Dollar Amount $7.00 OK: 678594:;
    # *	Dollar Amount $8.00 OK: 678594:;
    # *	Dollar Amount $9.00 OK: 678594:;
    # *	Dollar Amount $10.00 OK: 678594:;
    # *	Dollar Amount $15.00, if CVV2=1234 OK: 678594:; if there is no CVV2: REJ: 19
    # *	Dollar Amount $16.00 REJ: 2;
    # *	Other Amount REJ: 15.

    specify { order.should_receive(:valid_transaction?); order.run_transaction }

    it "should get a credit_card object" do
      order.should_receive(:credit_card).any_number_of_times.and_return(@credit_card)
      order.run_transaction
    end
    it "should set the authorization_result column if the credit card_processing is successful" do
      order.total = 1
      order.should_receive(:update_attributes).and_return(true)
      order.run_transaction
    end
    it "should create a tax receipt if the credit card_processing is successful" do
      order.total = 1
      order.country = "Canada"
      order.should_receive(:create_tax_receipt_from_order)
      order.run_transaction
    end
    it "should create a tax receipt if the credit card_processing is successful and country isn't Canada" do
      order.total = 1
      order.country = "Somewhere Else"
      order.should_receive(:create_tax_receipt_from_order).never
      order.run_transaction
    end
    it "should not set the authorization_result column if the credit card_processing is unsuccessful" do
      order.should_receive(:update_attributes).never
      lambda {
        order.total = 2
        order.run_transaction
      }
    end
    it "should not create a tax receipt if the credit card_processing is unsuccessful" do
      order.should_receive(:create_tax_receipt_from_order).never
      lambda {
        order.total = 2
        order.country = "Canada"
        order.run_transaction
      }
    end
    
    it "should return true when successful" do
      order.total = 1
      order.run_transaction.should be_true
    end
    it "should raise a ActiveMerchant::Billing::Error when passed an invalid credit_card" do
      @credit_card.should_receive(:valid?).and_return(false)
      lambda { 
        order.run_transaction 
      }.should raise_error(ActiveMerchant::Billing::Error)
    end
    # context "invalid amounts" do
    #   %w(2 4 5 16 100).each do |amount|
    #     it "should raise a ActiveMerchant::Billing::Error when not successful ($#{amount.to_i}.00)" do
    #       order.total = amount.to_i
    #       lambda { 
    #         order.run_transaction
    #       }.should raise_error(ActiveMerchant::Billing::Error)
    #     end
    #   end
    # end
    context "authorization results" do
      {"1" => "678594:", "3" => "678594:", "6" => "678594:", "7" => "678594:", "8" => "678594:", "9" => "678594:", "10" => "678594:"}.each do |amount, auth_result|
        it "should set the correct authorization_result for successful amounts ($#{amount}.00)" do
          order.total = amount.to_i
          order.run_transaction
          order.authorization_result.should =~ /\d+/
        end
      end
    end
    # 15.00, if CVV2=1234 OK: 678594:; if there is no CVV2: REJ: 19
    it "should set the correct authorization_result with a correct cvv" do
      order.total = 15
      @credit_card.verification_value = "1234"
      order.run_transaction
      order.authorization_result.should =~ /\d+/
    end
    it "should not raise an error with a blank cvv" do
      order.total = 15
      @credit_card.verification_value = nil
      lambda { 
        order.run_transaction
      }.should raise_error(ActiveMerchant::Billing::Error)
    end
  end
  
  describe "#create_order_with_investment_from_project_gift" do
    before do
      @gift = Factory(:gift, :project => Factory(:project))
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