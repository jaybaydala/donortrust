require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::PlaceTest < Test::Unit::TestCase
  fixtures :bus_admin_places#, :places, :place_types, :users

  context "BusAdmin::PlacesControllerTest handling GET " do
    include DtAuthenticatedTestHelper
    fixtures :places, :place_types, :users
  
    def do_get(place_id=1)
      get :index
    end
    
    specify "should create a place" do
      Place.should.differ(:count).by(1) {create_place} 
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