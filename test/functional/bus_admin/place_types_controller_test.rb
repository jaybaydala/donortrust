require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/place_types_controller'

# Re-raise errors caught by the controller.
class BusAdmin::PlaceTypesController; def rescue_action(e) raise e end; end

  context "BusAdmin::PlaceTypesControllerTest handling GET " do
    include DtAuthenticatedTestHelper
    fixtures :place_types, :users
  
    setup do
      @controller = BusAdmin::PlacesController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
  
   specify "should create a place type" do
      #PlaceType.should.differ(:count).by(1) {PlaceType.create(:name => 'TestPlaceType')}  
      PlaceType.should.differ(:count).by(1) { create_place_type }  
    end
    
    specify "should require name" do
      lambda {
        t = create_place_type(:name => nil)
        t.errors.on(:name).should.not.be.nil
        }.should.not.change(Place, :count)     
   end
   
   def create_place_type(options = {})
      PlaceType.create({ :name => 'TestPlaceType' }.merge(options))  
    end

end

