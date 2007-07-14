require File.dirname(__FILE__) + '/../test_helper'

context "Region" do
  fixtures :regions, :countries

setup do
    @region = Region.find(1)
  end

specify "duplicate name should not validate" do
   @region1 = Region.new( :region_name =>  @region.region_name )
    @region1.should.not.validate
    
end

specify "nil name should not validate" do
    @region.region_name = nil
    @region.should.not.validate
  end
  
specify "nil country_id should not validate" do
    @region.country_id = nil
    @region.should.not.validate
  end
 
end

