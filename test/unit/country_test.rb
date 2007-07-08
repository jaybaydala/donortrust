require File.dirname(__FILE__) + '/../test_helper'

context "Country" do
  fixtures :countries

setup do
    @countries = Country.find(1)
  end

specify "duplicate name should not validate" do
   @countries1 = Country.new( :name =>  @countries.name )
    @countries1.should.not.validate
    
end
specify "nil name should not validate" do
    @countries.name = nil
    @countries.should.not.validate
  end
  
 
end
