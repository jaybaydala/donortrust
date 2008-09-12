require File.dirname(__FILE__) + '/../test_helper'
#require 'bus_admin/place_types_controller'

context "PlaceType model" do
  include DtAuthenticatedTestHelper
  fixtures :place_types

  specify "should create a place type" do
    PlaceType.should.differ(:count).by(1) { create_place_type }  
  end
  
  specify "should require name" do
    lambda {
      t = create_place_type(:name => nil)
      t.errors.on(:name).should.not.be.nil
      }.should.not.change(PlaceType, :count)     
  end
 
  def create_place_type(options = {})
    PlaceType.create({ :name => 'TestPlaceType' }.merge(options))  
  end
end
