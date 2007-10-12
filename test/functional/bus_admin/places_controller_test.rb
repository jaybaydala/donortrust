require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/places_controller'

# Re-raise errors caught by the controller.
class BusAdmin::PlacesController; def rescue_action(e) raise e end; end

class BusAdmin::PlacesControllerTest < Test::Unit::TestCase
  fixtures :places
 
  context "BusAdmin::Places #route_for" do
     use_controller BusAdmin::PlacesController
    
     setup do
      @rs = ActionController::Routing::Routes
    end
  
    specify "should recognize the routes" do
      
      @rs.generate(:controller => "bus_admin/places", :action => "index").should.equal "/bus_admin/places"
    end 
    
  end

  context "BusAdmin::PlacesControllerTest handling GET " do
    include DtAuthenticatedTestHelper
    fixtures :places, :place_types, :users
  
    setup do
      @controller = BusAdmin::PlacesController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
  
    def do_get(place_id=1)
      get :index
    end
  
#    specify "should redirect to /login when not logged in" do
#      do_get
#      should.redirect dt_login_path()
#    end

  
    specify "should have an list method" do
      BusAdmin::PlacesController.new.should.respond_to 'list'
    end
    
    specify "should have an index method" do
      BusAdmin::PlacesController.new.should.respond_to 'index'
    end
  
    specify "should render the _description_form_column template" do
      login_as :quentin
      do_get
      template.should.be 'bus_admin/places/_description_form_column'    
    end 
    
    specify "should render the index template" do
      login_as :quentin
      do_get
      template.should.be 'bus_admin/places/index'    
    end 
    
    specify "should render the show template" do
      login_as :quentin
      do_get
      template.should.be 'bus_admin/places/show'    
    end 
    
    specify "should create a place" do
      Place.should.differ(:count).by(1) {Place.create(:name => 'TestPlace', :place_type_id => 1, :parent_id => 1, :description => 'My Description', :blog_url => 'blog_url', :rss_url => 'rss_url', :you_tube_reference => 1, :flickr_reference => 1, :facebook_group_id => 1)}  
    end
    
    specify "should require name" do
      lambda {
        t = create_place(:name => nil)
        t.errors.on(:name).should.not.be.nil
        }.should.not.change(Place, :count)
    end
    
    specify "should require place_type_id" do
      lambda {
        t = create_place(:place_type_id => nil)
        t.errors.on(:place_type_id).should.not.be.nil
        }.should.not.change(Place, :count)
    end
    
    specify "should not require parent_id" do 
      lambda {
        t = create_place(:parent_id => nil)
        t.errors.on(:parent_id).should.be.nil
      }.should.change(Place, :count)
    end   

   specify "should not require description" do 
      lambda {
        t = create_place(:description => nil)
        t.errors.on(:description).should.be.nil
      }.should.change(Place, :count)
    end
  
   specify "should not require blog_url" do
      lambda {
        t = create_place(:blog_url => nil)
        t.errors.on(:blog_url).should.be.nil
      }.should.change(Place, :count)
    end
  
   specify "should not require rss_url" do
      lambda {
        t = create_place(:rss_url => nil)
        t.errors.on(:rss_url).should.be.nil
      }.should.change(Place, :count)
    end  
  
   specify "should not require you_tube_reference" do
      lambda {
        t = create_place(:you_tube_reference => nil)
        t.errors.on(:you_tube_reference).should.be.nil
      }.should.change(Place, :count)
    end
  
   specify "should not require flickr_reference" do
      lambda {
        t = create_place(:flickr_reference => nil)
        t.errors.on(:flickr_reference).should.be.nil
      }.should.change(Place, :count)
    end
  
   specify "should not require facebook_group_id" do 
      lambda {
        t = create_place(:facebook_group_id => nil)
        t.errors.on(:facebook_group_id).should.be.nil
      }.should.change(Place, :count)
    end  
    
#    private
    def create_place(options = {})
      Place.create({ :name => 'TestPlace', :place_type_id => 1, :parent_id => 1, :description => 'My Description', :blog_url => 'blog_url', :rss_url => 'rss_url', :you_tube_reference => 1, :flickr_reference => 1, :facebook_group_id => 1 }.merge(options))  
    end
     
 end
  
end