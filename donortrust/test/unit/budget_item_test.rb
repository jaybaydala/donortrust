require File.dirname(__FILE__) + '/../test_helper'

# see user_transaction_test.rb for amount and user tests
context "BudgetItem" do
  fixtures :budget_items, :projects 

  setup do
    @budget = BudgetItem.new
  end
  
  def create_budget(options = {})
    BudgetItem.create({ :project_id => 1, :description => "Test Functions", :cost => 1000 }.merge(options))
  end
   specify "Budget table should be 'budgets'" do
    BudgetItem.table_name.should.equal 'budget_items'
  end
  
  
   specify "should create a budget" do
    BudgetItem.should.differ(:count).by(1) { create_budget } 
  end
  
  
   specify "should require project_id" do
    lambda {
      t = create_budget(:project_id => nil)
      t.errors.on(:project_id).should.not.be.nil
    }.should.not.change(BudgetItem, :count)
  end
  
  
   specify "should require cost" do
    lambda {
      t = create_budget(:cost => nil)
      t.errors.on(:cost).should.not.be.nil
    }.should.not.change(BudgetItem, :count)
  end

  specify "cost should be numerical" do
    lambda {
      t = create_budget(:cost => "hello")
      t.errors.on(:cost).should.not.be.nil
    }.should.not.change(BudgetItem, :count)
  end
 
end

