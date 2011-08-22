require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/wishlists_controller'

# Re-raise errors caught by the controller.
class Dt::WishlistsController; def rescue_action(e) raise e end; end

context "Dt::Wishlists inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::WishlistsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Wishlists #route_for" do
  use_controller Dt::WishlistsController

  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/wishlists', :action => 'new' } to /dt/wishlists/new" do
    route_for(:controller => "dt/wishlists", :action => "new").should == "/dt/wishlists/new"
  end

  specify "should map { :controller => 'dt/wishlists', :action => 'create' } to /dt/wishlists" do
    route_for(:controller => "dt/wishlists", :action => "create").should == "/dt/wishlists"
  end

  specify "should map { :controller => 'dt/wishlists', :action => 'destroy', :id => 1 } to /dt/wishlists" do
    route_for(:controller => "dt/wishlists", :action => "destroy", :id => 1).should == "/dt/wishlists/1"
  end

  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Wishlists handling GET /dt/wishlists/new" do
  use_controller Dt::WishlistsController
  include DtAuthenticatedTestHelper
  fixtures :users
  
  specify "should redirect if not logged_in" do
    get :new
    should.redirect login_path
  end

  specify "should redirect to projects if no project_id is provided" do
    login_as :quentin
    get :new
    should.redirect dt_projects_path
  end
  
  specify "should use dt/wishlists/new template" do
    login_as :quentin
    get :new, :project_id => 1
    template.should.be "dt/wishlists/new"
  end

  specify "should assign @project" do
    login_as :quentin
    get :new, :project_id => 1
    assigns(:project).should.not.be.nil
  end

  specify "should contain form#wishlistform with appropriate fields" do
    login_as :quentin
    get :new, :project_id => 1
    assert_select "form#wishlistform" do
      assert_select "select#group_id"
      assert_select "input[type=hidden]#project_id"
    end
  end
end

context "Dt::Wishlists handling POST /dt/wishlists" do
  use_controller Dt::WishlistsController
  include DtAuthenticatedTestHelper
  fixtures :users

  specify "should redirect if not logged_in" do
    do_post
    should.redirect login_path
  end

  specify "should redirect to projects if no project_id is provided" do
    login_as :quentin
    do_post(:project_id => nil)
    should.redirect dt_projects_path
  end
  
  specify "should assign @group if watchlisttype != 'personal'" do
    login_as :quentin
    do_post(:group_id => 1)
    assigns(:group).should.not.be.nil
  end

  specify "should redirect to group_projects page if watchlisttype != 'personal'" do
    login_as :quentin
    do_post(:group_id => 1)
    should.redirect dt_group_projects_path(assigns(:group))
  end

  specify "should increase group.projects.size by one if passed a group" do
    login_as :quentin
    old_count = Group.find(1).projects.size
    do_post(:group_id => 1)
    Group.find(1).projects.size.should.equal old_count+1
  end

  def do_post(options={})
    post :create, {:group_id => 1, :project_id => 1}.merge(options)
  end
end