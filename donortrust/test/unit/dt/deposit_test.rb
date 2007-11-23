require File.dirname(__FILE__) + '/../../test_helper'

# see user_transaction_test.rb for amount and user tests
context "Deposit" do
  include DtAuthenticatedTestHelper
  fixtures :user_transactions, :deposits, :gifts, :investments

  setup do
  end

  specify "Deposit should extend UserTransactionType" do
    #Deposit.base_class.should.be UserTransactionType
  end

  specify "Deposit table should be 'deposits'" do
    Deposit.table_name.should.equal 'deposits'
  end

  specify "should create a deposit" do
    Deposit.should.differ(:count).by(1) { create_deposit } 
  end

  specify "should require user_id" do
    lambda {
      t = create_deposit(:user_id => nil)
      t.errors.on(:user_id).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "should require amount" do
    lambda {
      t = create_deposit(:amount => nil)
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "amount should be numerical" do
    lambda {
      t = create_deposit(:amount => "hello")
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "amount should be positive" do
    lambda {
      t = create_deposit(:amount => 0)
      t.errors.on(:amount).should.not.be.nil
      t = create_deposit(:amount => -1)
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "should require credit_card" do
    lambda {
      t = create_deposit(:credit_card => nil)
      t.errors.on(:credit_card).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "should error on invalid credit_card" do
    lambda {
      t = create_deposit(:credit_card => 4111111111111112 )
      t.errors.on(:credit_card).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "should require card_expiry" do
    lambda {
      t = create_deposit(:card_expiry => nil)
      t.errors.on(:card_expiry).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end
  
  specify "should require first_name last_name address city postal_code country" do
    %w( first_name last_name address city postal_code country ).each {|f|
      lambda {
        fsym = f.to_sym
        t = create_deposit(fsym => nil)
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
      t = create_deposit(:card_expiry => exp)
      t.errors.on(:card_expiry).should.be.nil
    end
    [ today-365, today-31 ].each do |exp|
      t = create_deposit(:card_expiry => exp)
      t.errors.on(:card_expiry).should.not.be.nil
    end
  end

  specify "should error on invalid card_expiry" do
    lambda {
      t = create_deposit(:card_expiry => 4009 )
      t.errors.on(:card_expiry).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "if a gift_id is present, should not require credit_card, card_expiry or authorization_result" do
    lambda {
      t = create_deposit(:gift_id => 1, :credit_card => nil, :card_expiry => nil, :authorization_result =>nil )
      t.errors.on(:credit_card).should.be.nil
      t.errors.on(:card_expiry).should.be.nil
      t.errors.on(:authorization_result).should.be.nil
    }.should.change(Deposit, :count)
  end

  specify "creating a Deposit should create a UserTransaction" do
    lambda {
      t = create_deposit()
    }.should.change(UserTransaction, :count)
  end

  specify "sum should return a positive amount" do
    t = create_deposit()
    t.sum.should.be > 0
  end

  specify "credit_card should only contain the last 4 digits after save" do
    t = create_deposit( :credit_card => 4111111111111111 )
    t.credit_card.should.equal "1111"
  end
  
  specify "amount should strip a prepended $" do
    lambda {
      t = create_deposit( :amount => '$100.00' )
      t.errors.on(:amount).should.be.nil
      t.amount.should.equal 100.00
    }.should.change(Deposit, :count)
  end

  private
  def create_deposit(options = {})
    Deposit.create({ :amount => 1, :user_id => 1, :first_name => 'Tim', :last_name => 'Glen', :address => '36 Example St.', :city => 'Guelph', :province => 'ON', :postal_code => 'N1E 7C5', :country => 'Canada', :credit_card => 4111111111111111, :card_expiry => '04/09', :authorization_result => '1234' }.merge(options))
  end
end
