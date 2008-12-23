require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before do
    # @order = mock_model(Order)
    # @gift = mock_model(Gift)
    # @deposit = mock_model(Deposit)
    # @investment = mock_model(Investment)
    # @gift.stub!(:valid?).and_return(true)
    # @deposit.stub!(:valid?).and_return(true)
    # @investment.stub!(:valid?).and_return(true)
  end
  
  it "should create a user" do
    lambda {
      create_user
    }.should change(User, :count).by(1)
  end
  
  describe "a login must be a valid email" do
    it "should have a domain" do
      lambda {
        create_user :login => 'test1@com'
      }.should_not change(User, :count)
    end
    it "should have a tld" do
      lambda {
        create_user :login => 'test1@example'
      }.should_not change(User, :count)
    end
    %w(! # $ % ^ & * \( \) [ ] = , : ; ' ").each do |c|
      it "should not allow weird characters (#{c})" do
        lambda {
          create_user :login => 'test1@example'
        }.should_not change(User, :count)
      end
    end
  end
  
  describe "login" do
    it "should be unique" do
      lambda {
        create_user :login => 'duplicate@example.com'
        create_user :login => 'duplicate@example.com'
      }.should change(User, :count).by(1)
    end
    it "should be less than 100 characters" do
      lambda {
        t = create_user :login => 'This will enter more then 100 characters into the column. This will enter more then 100 characters into the column.'
        t.errors.on(:login).should_not be_nil
      }.should_not change(User, :count)
    end
    it "login should be a minimum of 3 Characters" do
      lambda {
        t = create_user(:login=> 'aa')
        t.errors.on(:login).should_not be_nil
      }.should_not change(User, :count)
    end
  end
  
  describe "password" do
    it "should be less than 40 Characters" do
      lambda {
        t = create_user(:password=> 'This will enter more then one 40 characters into the column.')
        t.errors.on(:password).should_not be_nil
      }.should_not change(User, :count)
    end

    it "should be a minimum of 4 Characters" do
      lambda {
        t = create_user(:password=> '123')
        t.errors.on(:password).should_not be_nil
      }.should_not change(User, :count)
    end
  end
  
  describe "must have either last_name and first_name OR a display_name" do
    it "should require a last_name if no display_name" do
      lambda {
        create_user :display_name => nil, :last_name => nil
      }.should_not change(User, :count)
    end
    it "should require a first_name if no display_name" do
      lambda {
        create_user :display_name => nil, :first_name => nil
      }.should_not change(User, :count)
    end
    it "should require a display_name if no first_name or last_name" do
      lambda {
        create_user :display_name => nil, :first_name => nil, :last_name => nil
      }.should_not change(User, :count)
    end
    it "should allow a display_name if no first_name or last_name" do
      lambda {
        create_user :display_name => "test", :first_name => nil, :last_name => nil
      }.should change(User, :count)
    end
    it "should allow a first_name and last_name if no display_name" do
      lambda {
        create_user :display_name => nil, :first_name => "Test", :last_name => "User"
      }.should change(User, :count)
    end
  end
  
  describe "country validation" do
    it "should require country" do
      lambda {
        t = create_user(:country => nil)
        t.errors.on(:country).should_not be_nil
      }.should_not change(User, :count)
    end
    describe "under_thirteen" do
      before do 
        @under_thirteen_data = { :under_thirteen => true, :first_name => nil, :last_name => nil, :address => nil, :city => nil, :province => nil, :postal_code => nil, :country => nil }
      end
      it "should save" do
        lambda {
          t = create_user(@under_thirteen_data)
        }.should change(User, :count).by(1)
      end
      
      %w(first_name last_name address city province postal_code country).each do |c|
        it "should not allow any personal data (#{c})" do
          lambda {
            t = create_user(@under_thirteen_data.merge(c.to_sym => "foo"))
            t.errors.on(c.to_sym).should_not be_nil
          }.should_not change(User, :count)
        end
      end
    end
  
    it "should return true if in specified country" do
      t = create_user({:country => 'Canada'})
      t.in_country?('Canada').should be_true
    end
  
    it "should return false if not in specified country" do
      t = create_user({:country => 'blah'})
      t.in_country?('Canada').should be_false
    end
  
    it "should return false if user's country is nil" do
      t = create_user({:country => nil})
      t.in_country?('Canada').should be_false
    end
  
    it "should return false if specified country is nil" do
      t = create_user({:country => 'Canada'})
      t.in_country?(nil).should be_false
    end
  end
  
  describe "deposited method" do
    before do
      @deposit1 = mock_model(Deposit, :amount => 75.0)
      @deposit2 = mock_model(Deposit, :amount => 25.0)
      @user = create_user
      @user.stub!(:deposits).and_return([@deposit1, @deposit2])
    end
    it "should return the total of all deposits" do
      @user.deposited.should == 100.0
    end
  end

  describe "invested method" do
    before do
      @investment1 = mock_model(Investment, :amount => 90.0)
      @investment2 = mock_model(Investment, :amount => 25.0)
      @user = create_user
      @user.stub!(:investments).and_return([@investment1, @investment2])
    end
    it "should return the total of all investments" do
      @user.invested.should == 115.0
    end
  end
  
  describe "gifted method" do
    before do
      @gift1 = mock_model(Gift, :amount => 110.0, :credit_card => "4111111111111111")
      @gift2 = mock_model(Gift, :amount => 25.0, :credit_card => nil)
      @user = create_user
    end
    it "should return the total of all gifts" do
      @user.should_receive(:gifts).and_return([@gift1, @gift2])
      @user.gifted.should == 135.0
    end
    it "should return the total of only credit_card gifts if exclude_credit_card is true" do
      @user.gifts.should_receive(:find).with(:all, :conditions => {:credit_card => nil}).and_return([@gift2])
      @user.gifted(true).should == 25.0
    end
  end
  
  describe "balance" do
    before do
      @deposit1 = mock_model(Deposit, :amount => 500.0)
      @deposit2 = mock_model(Deposit, :amount => 25.0)
      @investment1 = mock_model(Investment, :amount => 90.0)
      @investment2 = mock_model(Investment, :amount => 25.0)
      @gift1 = mock_model(Gift, :amount => 110.0, :credit_card => "4111111111111111")
      @gift2 = mock_model(Gift, :amount => 25.0, :credit_card => nil)
      @order1 = mock_model(Order, :complete => true, :amount => 100, :account_balance_payment => 90, :credit_card_balance => nil)
      @order2 = mock_model(Order, :complete => true, :amount => 120, :account_balance_payment => nil, :credit_card_balance => 160)
      @order3 = mock_model(Order, :complete => false, :amount => 5000, :account_balance_payment => nil, :credit_card_balance => nil)
      @orders = [@order1, @order2, @order3]
      # stub the user model
      @user = create_user
      @user.stub!(:deposits).and_return([@deposit1, @deposit2])
      @user.stub!(:investments).and_return([@investment1, @investment2])
      @user.stub!(:gifts).and_return([@gift1, @gift2])
      @user.stub!(:orders).and_return(@orders)
      # stub the necessary child models
      @user.orders.stub!(:find_all_by_complete).and_return([@order1])
      @user.investments.stub!(:find).and_return([])
      @user.gifts.stub!(:find).and_return([])
    end
    
    it "should return the users balance" do
      @user.balance.should == 435.0
    end
    it "should subtract any investments made without orders (old investments)" do
      @user.investments.should_receive(:find).with(:all, :conditions => {:order_id => nil}).and_return([@investment2])
      @user.balance.should == 410.0
    end
    it "should subtract any gifts made without orders (old gifts) or credit_card" do
      @user.gifts.should_receive(:find).with(:all, :conditions => {:order_id => nil, :credit_card => nil}).and_return([@gift1])
      @user.balance.should == 325.0
    end
  end
  
  describe "pledge_accounts" do
    # pledge accounts come directly from the pledge_deposits table, which has a user_id. 
    # there is one pledge account for each unique campaign in the pledge_deposits table
    
  end
  
  def create_user(options = {})
    User.create({ :login => 'login@example.com', :first_name => 'FirstName', :last_name => 'LastName', :display_name => 'DisplayName', :address => '4320 15 st', :city => 'Calgary', :province => 'Alberta', :country => 'Canada', :postal_code => 'T2T4B2', :under_thirteen => 0, :crypted_password => '00742970dc9e6319f8019fd54864d3ea740f04b1', :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', :created_at => '2006-10-16 13:14:40', :updated_at => '2007-10-16 13:14:40', :remember_token => 'test', :remember_token_expires_at => '2011-10-16 13:14:40', :activation_code => 'code', :activated_at => '2007-10-16 13:14:40', :last_logged_in_at => '2007-09-16 13:14:40', :terms_of_use => "1" }.merge(options))
  end
end
