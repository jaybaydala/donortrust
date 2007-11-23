require File.dirname(__FILE__) + '/../../test_helper'

context "User Transaction" do
  include DtAuthenticatedTestHelper
  fixtures :user_transactions, :users

  setup do
  end

  specify "should create a transaction" do
    UserTransaction.should.differ(:count).by(1) { create_transaction } 
  end

  specify "should require user_id" do
    lambda {
      t = create_transaction(:user_id => nil)
      t.errors.on(:user_id).should.not.be.nil
    }.should.not.change(UserTransaction, :count)
  end

  specify "should require tx" do
    lambda {
      t = create_transaction(:tx => nil)
      t.errors.on(:tx).should.not.be.nil
    }.should.not.change(UserTransaction, :count)
  end

  #specify "value should return a positive amount if tx_type == 1" do
  #  t = create_transaction(:amount => 200.00, :tx_type => 1)
  #  t.value.should.equal 200
  #end
  #
  #specify "value should return a negative amount if tx_type == -1" do
  #  t = create_transaction(:amount => 200.00, :tx_type => -1)
  #  t.value.should.equal -200
  #end

  private
  def create_transaction(options = {})
    UserTransaction.create({ :user_id => 1, :tx_type => 'Gift', :tx_id => 1 }.merge(options))
  end
end