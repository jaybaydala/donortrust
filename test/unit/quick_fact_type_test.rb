require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::QuickFactTypeTest < Test::Unit::TestCase
  fixtures :quick_fact_type

  context "QuickFactTests " do
    
    specify "should create a QuickFactType" do
      QuickFactType.should.differ(:count).by(1) { create_quick_fact } 
    end
    
    specify "should require name" do
        lambda {
          t = create_quick_fact(:name => nil)
          t.errors.on(:name).should.not.be.nil
        }.should.not.change(QuickFactType, :count)
      end
      
    specify "name should be unique" do
      @fact = create_quick_fact()
      @fact.save
      @fact = create_quick_fact()
      @fact.should.not.validate
    end   
     
     def create_quick_fact(options = {})
        QuickFactType.create({ :name => 'QuickFactName', :description => 'My Description' }.merge(options))  
                                           
      end                                                          
    end
end
