require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/my_wishlists_controller'

# Re-raise errors caught by the controller.
class Dt::MyWishlistsController; def rescue_action(e) raise e end; end

context "Dt::MyWishlists inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::MyWishlistsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::MyWishlists #route_for" do
  use_controller Dt::MyWishlistsController

  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/my_wishlists', :action => 'index', :account_id => 1 } to /dt/accounts/1/my_wishlists" do
    route_for(:controller => "dt/my_wishlists", :action => "index", :account_id => 1).should == "/dt/accounts/1/my_wishlists"
  end
  
  specify "should map { :controller => 'dt/my_wishlists', :action => 'new', :account_id => 1 } to /dt/accounts/1/my_wishlists/new" do
    route_for(:controller => "dt/my_wishlists", :action => "new", :account_id => 1).should == "/dt/accounts/1/my_wishlists/new"
  end
  
  specify "should map { :controller => 'dt/my_wishlists', :action => 'create', :account_id => 1 } to /dt/accounts/1/my_wishlists" do
    route_for(:controller => "dt/my_wishlists", :action => "create", :account_id => 1).should == "/dt/accounts/1/my_wishlists"
  end
  
  specify "should map { :controller => 'dt/my_wishlists', :action => 'show', :id => 1, :account_id => 1 } to /dt/accounts/1/my_wishlists/1" do
    route_for(:controller => "dt/my_wishlists", :action => "show", :id => 1, :account_id => 1).should == "/dt/accounts/1/my_wishlists/1"
  end
  
  specify "should map { :controller => 'dt/my_wishlists', :action => 'edit', :id => 1, :account_id => 1 } to /dt/accounts/1/my_wishlists/1;edit" do
    route_for(:controller => "dt/my_wishlists", :action => "edit", :id => 1, :account_id => 1).should == "/dt/accounts/1/my_wishlists/1;edit"
  end
  
  specify "should map { :controller => 'dt/my_wishlists', :action => 'update', :id => 1, :account_id => 1} to /dt/accounts/1/my_wishlists/1" do
    route_for(:controller => "dt/my_wishlists", :action => "update", :id => 1, :account_id => 1).should == "/dt/accounts/1/my_wishlists/1"
  end
  
  specify "should map { :controller => 'dt/my_wishlists', :action => 'destroy', :id => 1, :account_id => 1} to /dt/accounts/1/my_wishlists/1" do
    route_for(:controller => "dt/my_wishlists", :action => "destroy", :id => 1, :account_id => 1).should == "/dt/accounts/1/my_wishlists/1"
  end

  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::MyWishlists handling GET /dt/my_wishlists" do
  use_controller Dt::MyWishlistsController
  fixtures :users
  include DtAuthenticatedTestHelper

  def do_get(account_id = 1)
    get :index, :account_id => account_id
  end
  
  specify "should get redirected if !logged_in?" do
    do_get
    response.should.redirect dt_login_path
  end
end
