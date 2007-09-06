require File.dirname(__FILE__) + '/../../test_helper'

# see user_transaction_test.rb for amount and user tests
context "Investment" do
  include DtAuthenticatedTestHelper
  fixtures :user_transactions, :investments

  setup do
  end

  specify "Investment table should be 'investments'" do
    Investment.table_name.should.equal 'investments'
  end

  specify "should create an investment" do
    Investment.should.differ(:count).by(1) { create_investment } 
  end

  specify "should require user_id" do
    lambda {
      t = create_investment(:user_id => nil)
      t.errors.on(:user_id).should.not.be.nil
    }.should.not.change(Investment, :count)
  end

  specify "should require amount" do
    lambda {
      t = create_investment(:amount => nil)
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Investment, :count)
  end

  specify "amount should be numerical" do
    lambda {
      t = create_investment(:amount => "hello")
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Investment, :count)
  end

  specify "amount should be positive" do
    lambda {
      t = create_investment(:amount => 0)
      t.errors.on(:amount).should.not.be.nil
      t = create_investment(:amount => -1)
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Investment, :count)
  end

  specify "should require project_id" do
    lambda {
      t = create_investment(:project_id => nil)
      t.errors.on(:project_id).should.not.be.nil
    }.should.not.change(Investment, :count)
  end
  
  specify "should not require group_id" do
    lambda {
      t = create_investment()
    }.should.change(Investment, :count)
  end
  
  specify "creating a Investment should create a UserTransaction" do
    lambda {
      t = create_investment()
    }.should.change(UserTransaction, :count)
  end

  private
  def create_investment(options = {})
    Investment.create({ :amount => 1, :user_id => 1, :project_id => 1, :group_id => 1 }.merge(options))
  end
end
