require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/place_searches_controller'

# Re-raise errors caught by the controller.
class Dt::PlacesSearchesController; def rescue_action(e) raise e end; end

context "Dt::PlaceSearches inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::PlaceSearchesController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end


context "Dt::PlaceSearches #route_for" do
  use_controller Dt::PlaceSearchesController
  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/place_searches', :action => 'index' } to /dt/place_searches" do
    route_for(:controller => "dt/place_searches", :action => "index").should == "/dt/place_searches"
  end
  
  specify "should map { :controller => 'dt/place_searches', :action => 'show', :id => 1 } to /dt/place_searches/1" do
    route_for(:controller => "dt/place_searches", :action => "show", :id => 1).should == "/dt/place_searches/1"
  end
  
  specify "should map { :controller => 'dt/place_searches', :action => 'new' } to /dt/place_searches/new" do
    route_for(:controller => "dt/place_searches", :action => "new").should == "/dt/place_searches/new"
  end
  
  specify "should map { :controller => 'dt/place_searches', :action => 'create' } to /dt/place_searches" do
    route_for(:controller => "dt/place_searches", :action => "create").should == "/dt/place_searches"
  end
    
  specify "should map { :controller => 'dt/place_searches', :action => 'edit', :id => 1 } to /dt/place_searches/1;edit" do
    route_for(:controller => "dt/place_searches", :action => "edit", :id => 1).should == "/dt/place_searches/1;edit"
  end
  
  specify "should map { :controller => 'dt/place_searches', :action => 'update', :id => 1} to /dt/place_searches/1" do
    route_for(:controller => "dt/place_searches", :action => "update", :id => 1).should == "/dt/place_searches/1"
  end
  
  specify "should map { :controller => 'dt/place_searches', :action => 'destroy', :id => 1} to /dt/place_searches/1" do
    route_for(:controller => "dt/place_searches", :action => "destroy", :id => 1).should == "/dt/place_searches/1"
  end

  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Gifts show, new, create, edit, update and destroy should not exist "do
  use_controller Dt::PlaceSearchesController
  specify "methods should not exist" do
    %w( index show new edit update destroy ).each do |m|
      @controller.methods.should.not.include m
    end
  end
end

context "Dt::PlaceSearches search behaviour"do
  use_controller Dt::PlaceSearchesController
  fixtures :places, :place_types
  include DtAuthenticatedTestHelper

  specify "should use the dt/place_searches/create.rjs template" do
    do_post
    template.should.be 'dt/place_searches/create.rjs'
  end
  
  specify "should respond to the js format" do
    accept 'text/javascript'
    do_post
    @response.headers['Content-Type'].should.match /^text\/javascript/
  end
  
  def do_post(options={})
    post :create, { :name => 'ka', :place_type_id => 6, :parent_id => 6 }.merge(options)
  end
end
