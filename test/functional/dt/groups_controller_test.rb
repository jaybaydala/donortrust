require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/groups_controller'
require 'pp'

# Re-raise errors caught by the controller.
class Dt::GroupsController; def rescue_action(e) raise e end; end

context "Dt::Groups inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::GroupsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Groups #route_for" do
  setup do
    @controller = Dt::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @rs         = ActionController::Routing::Routes
  end

  specify "should recognize the routes" do
    @rs.generate(:controller => "dt/groups", :action => "index").should.equal "/dt/groups"
  end

  specify "should map { :controller => 'dt/groups', :action => 'index' } to /dt/groups" do
    route_for(:controller => "dt/groups", :action => "index").should == "/dt/groups"
  end
  
  specify "should map { :controller => 'dt/groups', :action => 'new' } to /dt/groups/new" do
    route_for(:controller => "dt/groups", :action => "new").should == "/dt/groups/new"
  end
  
  specify "should map { :controller => 'dt/groups', :action => 'show', :id => 1 } to /dt/groups/1" do
    route_for(:controller => "dt/groups", :action => "show", :id => 1).should == "/dt/groups/1"
  end
  
  specify "should map { :controller => 'dt/groups', :action => 'edit', :id => 1 } to /dt/groups/1;edit" do
    route_for(:controller => "dt/groups", :action => "edit", :id => 1).should == "/dt/groups/1;edit"
  end
  
  specify "should map { :controller => 'dt/groups', :action => 'update', :id => 1} to /dt/groups/1" do
    route_for(:controller => "dt/groups", :action => "update", :id => 1).should == "/dt/groups/1"
  end
  
  specify "should map { :controller => 'dt/groups', :action => 'destroy', :id => 1} to /dt/groups/1" do
    route_for(:controller => "dt/groups", :action => "destroy", :id => 1).should == "/dt/groups/1"
  end

  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::GroupsController authentication" do
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
  
  setup do
    @controller = Dt::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  xspecify "should not redirect to /dt/accounts;signin when logged in" do
    login_as :tim
    get :index
    should.not.redirect
    get :new
    should.not.redirect
    post :create
    should.not.redirect
    get :show, :id => 1
    should.not.redirect
    get :edit, :id => 1
    should.not.redirect
    put :update, :id => 1, :group => { :name => 'another test' }
    should.redirect dt_group_path(1)
    delete :destroy, :id => 1
    should.redirect dt_groups_path()
  end
end

context "Dt::GroupsController handling GET /dt/groups" do
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
  
  setup do
    @controller = Dt::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def do_get
    get :index
  end

  specify "should redirect to /dt/accounts;signin when not logged in" do
    do_get
    should.redirect dt_signin_accounts_path()
  end

  specify "should get index" do
    login_as :tim
    do_get
    status.should.be :success
    assigns(:groups).should.not.be nil
    template.should.be "dt/groups/index"
  end
end

context "Dt::GroupsController handling GET /dt/groups;new" do
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
  
  setup do
    @controller = Dt::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def do_get
    get :new
  end

  specify "should redirect to /dt/accounts;signin when not logged in" do
    do_get
    should.redirect dt_signin_accounts_path()
  end

  specify "should get new" do
    login_as :tim
    do_get
    status.should.be :success
    template.should.be "dt/groups/new"
  end
end

context "Dt::GroupsController handling POST /dt/groups;create" do
#When creating a group, I should:
#  x be required to enter a group name
#  x Group name does not have to be unique
#  x choose what type of group I'm creating - Corporate, School, Family, General, Special Interest
#  x set group to Public/Private
#  - choose geographic location of group
#    - Country and Province/state are pre-populated select boxes, city/town should be text box autocomplete (non-constrained)
#  - choose the sector/cause interest of the group
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
  
  setup do
    @controller = Dt::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  specify "should redirect to /dt/accounts;signin when not logged in" do
    create_group({}, false)
    should.redirect dt_signin_accounts_path()
  end

  specify "should create group" do
    old_count = Group.count
    create_group
    Group.count.should.equal old_count+1
    should.redirect dt_group_path(assigns(:group))
  end
  
  specify "should require a name" do
    lambda {
      create_group(:name => nil)
      assigns(:group).errors.on(:name).should.not.be.nil
      status.should.be :success
    }.should.not.change(Group, :count)
  end

  specify "should require a group type" do
    lambda {
      create_group(:group_type_id => nil)
      assigns(:group).errors.on(:group_type_id).should.not.be.nil
      status.should.be :success
    }.should.not.change(Group, :count)
  end
  
  
  def create_group(options = {}, login = true)
    login_as :tim if login == true
    post :create, :group => { :name => 'Test Group', :description => 'This is the group description', :private => 0, :group_type_id => 1 }.merge(options)
  end
end

context "Dt::GroupsController handling GET /dt/groups/1" do
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
  
  setup do
    @controller = Dt::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def do_get 
    get :show, :id => 1
  end

  specify "should redirect to /dt/accounts;signin when not logged in" do
    do_get
    should.redirect dt_signin_accounts_path()
  end

  specify "should show group" do
    login_as :tim
    do_get
    status.should.be :success
    template.should.be 'dt/groups/show'
  end

  protected
  def create_group(options = {})
    post :create, :group => { :name => 'Test Group', :description => 'This is the group description', :private => 0, :group_type_id => 1 }.merge(options)
  end
end

context "Dt::GroupsController handling GET /dt/groups/1;edit" do
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
  
  setup do
    @controller = Dt::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def do_get 
    get :edit, :id => 1
  end

  specify "should redirect to /dt/accounts;signin when not logged in" do
    do_get
    should.redirect dt_signin_accounts_path()
  end

  specify "should get edit" do
    login_as :tim
    do_get
    status.should.be :success
    template.should.be 'dt/groups/edit'
  end
end

context "Dt::GroupsController handling PUT /dt/groups/1" do
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
  
  setup do
    @controller = Dt::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  specify "should redirect to /dt/accounts;signin when not logged in" do
    put :update, :id => 1, :group => { :name => 'new name' }
    should.redirect dt_signin_accounts_path()
  end

  specify "should update group" do
    login_as :tim
    put :update, :id => 1, :group => { :name => 'new name' }
    should.redirect dt_group_path(assigns(:group))
  end
end

context "Dt::GroupsController handling DELETE /dt/groups/1" do
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
  
  setup do
    @controller = Dt::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  specify "should redirect to /dt/accounts;signin when not logged in" do
    delete :destroy, :id => 1
    should.redirect dt_signin_accounts_path()
  end

  specify "should destroy group" do
    login_as :tim
    old_count = Group.count
    delete :destroy, :id => 1
    Group.count.should.equal old_count-1
    should.redirect dt_groups_path
  end
end

#GROUP STORIES
#=============
#As a user, I should be able to:
#  x see a list of "public" groups
#  - not see "non-public" groups
#  - see a public groups' name & description
#  - join a public group
#  - not join a non-public group
#  - join a non-public group to which i've been invited
#  x create a group
#these will all allow a user to connect with people who share their interests
#
#When looking at a list of groups:
#  -  the group should show name, description, type, geographic location and interests
#
#As a group member, I should be able to:
#  - leave a group
#  - write on the group wall
#  - view other member's wall messages
#  - view group admin messages
#  - view "public" members
#  - not view "non-public" members
#  - see what projects the group is interested in
#  - see how much money the group has allocated to each project
#  - see the total amount of money the group has allocated
#these will all allow a community to form through the group model
#
#As a group-admin, I should be able to:
#  - edit the group name & description
#  - invite new existing DT account holders
#  - invite non-account holders via email
#  - make a current member a group admin
#  - remove admin status from another group-admin
#  - post group admin messages to the group
#  - add Projects to the "interested in" list
#  - remove Projects from the "interested in" list
#these will all allow a community to form through the group model
#
#As a group creator, I should:
#  - automaticallu be added as a member of the group
#  - be protected from other admins removing my admin status
#
#Low priority stories:
#Group Accounts
#  - Corporate Accounts (an Encana account where Encana will match employee giving)
#Group Competition:
#  - Competing with other groups to raise funds (ie. an Encana employee group competing against a Talisman Group)
#  - Group admin would send a competitiion invite would be sent to another existing group (of any kind)
#  - Invite must be accepted for competition to begin...
