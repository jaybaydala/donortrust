require File.dirname(__FILE__) + '/../../test_helper'

# see user_transaction_test.rb for amount and user tests
context "Gift" do
  include DtAuthenticatedTestHelper
  fixtures :user_transactions, :gifts

  setup do
  end

  specify "Gift should extend UserTransactionType" do
    Gift.base_class.should.be UserTransactionType
  end

  specify "Gift table should be 'gifts'" do
    Gift.table_name.should.equal 'gifts'
  end

  specify "should create a gift" do
    Gift.should.differ(:count).by(1) { create_gift } 
  end

  specify "should require user_id" do
    lambda {
      t = create_gift(:user_id => nil)
      t.errors.on(:user_id).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "should require amount" do
    lambda {
      t = create_gift(:amount => nil)
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Gift, :count)
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

  specify "should require to_user_id" do
    lambda {
      t = create_gift(:to_user_id => nil)
      t.errors.on(:to_user_id).should.not.be.nil
    }.should.not.change(Gift, :count)
  end
  
  specify "creating a Gift should create a UserTransaction" do
    lambda {
      t = create_gift()
    }.should.change(UserTransaction, :count)
  end

  private
  def create_gift(options = {})
    Gift.create({ :amount => 1, :user_id => 1, :to_user_id => 2 }.merge(options))
  end
end
