require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/watchlists_controller'

# Re-raise errors caught by the controller.
class Dt::WatchlistsController; def rescue_action(e) raise e end; end

context "Dt::Watchlists inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::WatchlistsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Accounts #route_for" do
  use_controller Dt::WatchlistsController

  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/watchlists', :action => 'new' } to /dt/watchlists/new" do
    route_for(:controller => "dt/watchlists", :action => "new").should == "/dt/watchlists/new"
  end

  specify "should map { :controller => 'dt/watchlists', :action => 'create' } to /dt/watchlists" do
    route_for(:controller => "dt/watchlists", :action => "create").should == "/dt/watchlists"
  end

  specify "should map { :controller => 'dt/watchlists', :action => 'destroy', :id => 1 } to /dt/watchlists" do
    route_for(:controller => "dt/watchlists", :action => "destroy", :id => 1).should == "/dt/watchlists/1"
  end

  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Accounts handling GET /dt/watchlists/new" do
  use_controller Dt::WatchlistsController
  include DtAuthenticatedTestHelper
  fixtures :users
  
  specify "should redirect if not logged_in" do
    get :new
    should.redirect dt_login_path
  end
  
  specify "should use dt/watchlists/new template" do
    login_as :quentin
    get :new
    template.should.be "dt/watchlists/new"
  end

  specify "should contain form#watchlistform with appropriate fields" do
    login_as :quentin
    get :new
    assert_select "form#watchlistform" do
      assert_select "select#watchlisttype"
    end
  end
end