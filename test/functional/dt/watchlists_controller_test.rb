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

  specify "should redirect to projects if no project_id is provided" do
    login_as :quentin
    get :new
    should.redirect dt_projects_path
  end
  
  specify "should use dt/watchlists/new template" do
    login_as :quentin
    get :new, :project_id => 1
    template.should.be "dt/watchlists/new"
  end

  specify "should assign @project" do
    login_as :quentin
    get :new, :project_id => 1
    assigns(:project).should.not.be.nil
  end

  specify "should contain form#watchlistform with appropriate fields" do
    login_as :quentin
    get :new, :project_id => 1
    assert_select "form#watchlistform" do
      assert_select "select#watchlisttype"
    end
  end
end

context "Dt::Accounts handling POST /dt/watchlists" do
  use_controller Dt::WatchlistsController
  include DtAuthenticatedTestHelper
  fixtures :users

  specify "should redirect if not logged_in" do
    do_post
    should.redirect dt_login_path
  end

  specify "should redirect to projects if no project_id is provided" do
    login_as :quentin
    do_post(:project_id => nil)
    should.redirect dt_projects_path
  end
  
  specify "should redirect to personal watchlists page ir watchlisttype == 'personal'" do
    login_as :quentin
    do_post(:watchlist_type => 'personal')
    should.redirect dt_wishlists_path(@controller.send('current_user'))
  end

  specify "should assign @group if watchlisttype != 'personal'" do
    login_as :quentin
    do_post(:watchlist_type => 'group-1')
    assigns(:group).should.not.be.nil
  end

  specify "should redirect to group_projects page if watchlisttype != 'personal'" do
    login_as :quentin
    do_post(:watchlist_type => 'group-1')
    should.redirect dt_group_projects_path(assigns(:group))
  end

  specify "should increase group.projects.size by one if passed a group" do
    login_as :quentin
    old_count = Group.find(1).projects.size
    do_post(:watchlist_type => 'group-1')
    Group.find(1).projects.size.should.equal old_count+1
  end

  specify "should increase Wishlists.count by one if passed personal" do
    login_as :quentin
    old_count = Wishlist.count
    do_post(:watchlist_type => 'personal')
    Wishlist.count.should.equal old_count+1
  end
  
  def do_post(options={})
    post :create, {:watchlist_type => 'personal', :project_id => 1}.merge(options)
  end
end