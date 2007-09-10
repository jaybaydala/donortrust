require File.dirname(__FILE__) + '/../../test_helper'

# see user_transaction_test.rb for amount and user tests
context "Gift" do
  include DtAuthenticatedTestHelper
  fixtures :user_transactions, :gifts, :users

  setup do
  end

  specify "Gift table should be 'gifts'" do
    Gift.table_name.should.equal 'gifts'
  end

  specify "should create a gift" do
    Gift.should.differ(:count).by(1) { create_gift } 
  end

  specify "if there's no user_id, the credit_card parameters are required" do
    lambda {
      t = create_gift(:user_id => nil)
      t.errors.on(:credit_card).should.not.be.nil
    }.should.not.change(Gift, :count)
    lambda {
      t = create_gift(credit_card_params(:user_id => nil))
      t.errors.on(:credit_card).should.be.nil
    }.should.change(Gift, :count)
  end

  specify "should require amount" do
    lambda {
      t = create_gift(:amount => nil)
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "should not require a message" do
    lambda {
      t = create_gift(credit_card_params(:message => nil))
      t.errors.on(:mesasge).should.be.nil
    }.should.change(Gift, :count)
  end

  specify "amount should be numerical" do
    lambda {
      t = create_gift(:amount => "hello")
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "amount should be positive" do
    lambda {
      t = create_gift(:amount => 0)
      t.errors.on(:amount).should.not.be.nil
      t = create_gift(:amount => -1)
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "should not require to_name" do
    lambda {
      t = create_gift(credit_card_params(:to_name => nil))
      t.errors.on(:to_name).should.be.nil
    }.should.change(Gift, :count)
  end
  
  specify "should require to_email" do
    lambda {
      t = create_gift(:to_email => nil)
      t.errors.on(:to_email).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "should not require name" do
    lambda {
      t = create_gift(credit_card_params(:name => nil))
      t.errors.on(:name).should.be.nil
    }.should.change(Gift, :count)
  end
  
  specify "should require email" do
    lambda {
      t = create_gift(:email => nil)
      t.errors.on(:email).should.not.be.nil
    }.should.not.change(Gift, :count)
  end
  
  specify "creating a Gift should create a UserTransaction if user_id is present" do
    lambda {
      t = create_gift()
    }.should.not.change(UserTransaction, :count)
    
    lambda {
      t = create_gift(credit_card_params(:user_id => 1))
    }.should.change(UserTransaction, :count)
  end

  specify "sum should return a negative amount" do
    t = create_gift()
    t.sum.should.be < 0
  end

  specify "should error on invalid credit_card" do
    lambda {
      t = create_gift(:credit_card => 4111111111111112 )
      t.errors.on(:credit_card).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "should require card_expiry first_name last_name address city postal_code country if credit_card != nil" do
    %w( card_expiry first_name last_name address city postal_code country ).each {|f|
      lambda {
        fsym = f.to_sym
        t = create_gift(:credit_card => 4111111111111111, fsym => nil)
        t.errors.on(fsym).should.not.be.nil
      }.should.not.change(Deposit, :count)
    }
  end

  specify "card_expiry= should take a variety of formats and come out as the last day the month specified" do
    date = Date.civil(2009, 4, -1).to_s
    d = Deposit.new
    [ "04/09", "04/2009", "0409", "04 09", ["04", "09"], "2009-04-30", "2009-04-20", Date.civil(2009, 4, 20) ].each do |exp|
      d.card_expiry = exp
      d.card_expiry.to_s.should.equal date 
    end
  end

  specify "card_expiry= should be current or future" do
    d = Deposit.new
    today = Date.today
    [ today, Date.civil(today.year, today.month, -1), today+1, today+31, today+365 ].each do |exp|
      t = create_gift(:credit_card => 4111111111111111, :card_expiry => exp)
      t.errors.on(:card_expiry).should.be.nil
    end
    [ today-365, today-31 ].each do |exp|
      t = create_gift(:credit_card => 4111111111111111, :card_expiry => exp)
      t.errors.on(:card_expiry).should.not.be.nil
    end
  end

  specify "should error on invalid card_expiry" do
    lambda {
      t = create_gift(:credit_card => 4111111111111111, :card_expiry => 4009 )
      t.errors.on(:card_expiry).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "if user_id != nil and credit_card == nil, cannot give more than the user's current balance" do
    lambda {
      t = create_gift( :user_id => 1, :amount => 2000.00 )
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "should create a pickup_code" do
    t = create_gift
    t.pickup_code.should.not.be nil
  end

  private
  def credit_card_params(options = {})
    { :credit_card => 4111111111111111, :card_expiry => '04/09', :first_name => 'Tim', :last_name => 'Glen', :address => '36 Example St.', :city => 'Guelph', :province => 'ON', :postal_code => 'N1E 7C5', :country => 'CA' }.merge(options)
  end

  def create_gift(options = {})
    options = credit_card_params if options.empty?
    Gift.create({ :amount => 1, :to_name => 'To Name', :to_email => 'to@example.com', :name => 'From Name', :email => 'from@example.com', :message => 'hello world!' }.merge(options))
  end
end
