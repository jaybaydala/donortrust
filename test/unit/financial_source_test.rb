require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::FinancialSourceTest < Test::Unit::TestCase
  fixtures :financial_sources, :projects

  context "Financial Source Tests " do
   
   specify "should create a financial source" do
      FinancialSource.should.differ(:count).by(1) {create_financial} 
    end
    
    specify "amount should be numerical" do
      lambda {
        t = create_financial(:amount => 'test')
        t.errors.on(:amount).should.not.be.nil
      }.should.not.change(FinancialSource, :count)
    end
    
   specify "should require source" do
      lambda {
        t = create_financial(:source => nil)
        t.errors.on(:source).should.not.be.nil
      }.should.not.change(FinancialSource, :count)
   end
   
   specify "should require amount" do
      lambda {
        t = create_financial(:amount => nil)
        t.errors.on(:amount).should.not.be.nil
      }.should.not.change(FinancialSource, :count)
    end
    
     specify "should require project" do
      lambda {
        t = create_financial(:project => nil)
        t.errors.on(:project).should.not.be.nil
      }.should.not.change(FinancialSource, :count)
    end
   
  def create_financial(options = {})
     FinancialSource.create({ :project_id => 1, :source => 'My Description', :amount=> 1 }.merge(options))  
                                                
    end                                                          
  end
end
