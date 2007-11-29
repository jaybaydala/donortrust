require File.dirname(__FILE__) + '/../../test_helper'

# see user_transaction_test.rb for amount and user tests
context "Investment" do
  fixtures :investments, :deposits, :gifts, :user_transactions, :users, :groups

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

  specify "amount can't be more than the associated user.balance when there's no gift_id" do
    # we know that User(1) has a balance
    balance = User.find(1).balance
    lambda {
      t = create_investment(:amount => balance+0.01, :gift_id => nil)
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Investment, :count)
  end

  specify "amount can be more than the associated user.balance when there a gift_id" do
    # we know that User(1) has a balance
    balance = User.find(1).balance
    lambda {
      t = create_investment(:amount => balance+0.01, :gift_id => 1)
      t.errors.on(:amount).should.be.nil
    }.should.change(Investment, :count)
  end

  specify "amount should strip a prepended $" do
    lambda {
      t = create_investment( :amount => '$5.00' )
      t.errors.on(:amount).should.be.nil
      t.amount.should.equal 5.0
    }.should.change(Investment, :count)
  end

  specify "should require project_id" do
    lambda {
      t = create_investment(:project_id => nil)
      t.errors.on(:project_id).should.not.be.nil
    }.should.not.change(Investment, :count)
    lambda {
      t = create_investment(:project_id => 0)
      t.errors.on(:project_id).should.not.be.nil
    }.should.not.change(Investment, :count)
    lambda {
      t = create_investment(:project_id => -1)
      t.errors.on(:project_id).should.not.be.nil
    }.should.not.change(Investment, :count)
  end

  specify "should require user_id" do
    lambda {
      t = create_investment(:user_id => nil)
      t.errors.on(:user_id).should.not.be.nil
    }.should.not.change(Investment, :count)
    lambda {
      t = create_investment(:user_id => 0)
      t.errors.on(:user_id).should.not.be.nil
    }.should.not.change(Investment, :count)
    lambda {
      t = create_investment(:user_id => -1)
      t.errors.on(:user_id).should.not.be.nil
    }.should.not.change(Investment, :count)
  end
  
  specify "should not require group_id" do
    lambda {
      t = create_investment(:group_id => nil)
      t.errors.on(:group_id).should.be.nil
    }.should.change(Investment, :count)
  end
  
  specify "should not require gift_id" do
    lambda {
      t = create_investment(:gift_id => nil )
      t.errors.on(:gift_id).should.be.nil
    }.should.change(Investment, :count)
  end
  
  specify "creating a Investment should create a UserTransaction" do
    lambda {
      t = create_investment()
    }.should.change(UserTransaction, :count)
  end

  specify "sum should return a negative amount" do
    t = create_investment()
    t.sum.should.be < 0
  end
  
  specify "amount cannot be greater than the project.current_need" do
    @project = Project.find_public(:first)
    lambda {
      t = create_investment(:project_id => @project.id, :amount => @project.current_need + 1)
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Investment, :count)
  end
  
  private
  def create_investment(options = {})
    Investment.create({ :amount => 1, :user_id => 1, :project_id => 1, :group_id => 1, :gift_id => 1 }.merge(options))
  end
end
