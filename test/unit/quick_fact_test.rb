require File.dirname(__FILE__) + '/../test_helper'

context "Quick Fact Tests " do
  fixtures :quick_facts, :quick_fact_types
  
  specify "should create a quick fact" do
    QuickFact.should.differ(:count).by(1) {create_quick_fact} 
  end
  
  specify "should require name" do
    lambda {
      t = create_quick_fact(:name => nil)
      t.errors.on(:name).should.not.be.nil
    }.should.not.change(QuickFact, :count)
  end
 
  specify "should require quick fact type" do
    lambda {
      t = create_quick_fact(:quick_fact_type_id => nil)
      t.errors.on(:quick_fact_type_id).should.not.be.nil
    }.should.not.change(QuickFact, :count)
  end
 
  def create_quick_fact(options = {})
    QuickFact.create({ :name => 'Test', :description => 'Description', :quick_fact_type_id => 1 }.merge(options))  
  end    
end