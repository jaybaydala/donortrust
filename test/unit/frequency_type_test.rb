require File.dirname(__FILE__) + '/../test_helper'

context "Targets" do
  fixtures :frequency_types

setup do
    @frequency_types = FrequencyType.find(1)
  end
 
  specify "The frequency type should have a name" do
    @frequency_types.name.should.not.be.nil
    
  end

specify "duplicate name should not validate" do
   @frequency_types1 = FrequencyType.new( :name =>  @frequency_types.name )
    
    @frequency_types1.should.not.validate
    
end
specify "nil name should not validate" do
    @frequency_types.name = nil
    @frequency_types.should.not.validate
  end
  
 
end
