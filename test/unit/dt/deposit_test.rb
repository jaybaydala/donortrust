require File.dirname(__FILE__) + '/../../test_helper'

# see user_transaction_test.rb for amount and user tests
context "Deposit" do
  include DtAuthenticatedTestHelper
  fixtures :user_transactions, :deposits

  setup do
  end

  specify "Deposit should extend UserTransactionType" do
    Deposit.base_class.should.be UserTransactionType
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

  specify "creating a Deposit should create a UserTransaction" do
    lambda {
      t = create_deposit()
    }.should.change(UserTransaction, :count)
  end

  private
  def create_deposit(options = {})
    Deposit.create({ :amount => 1, :user_id => 1 }.merge(options))
  end
end
