require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/groups_controller'

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

  specify "should not redirect when not logged in" do
    do_get
    should.not.redirect
  end
  
  specify "should get index" do
    login_as :tim
    do_get
    status.should.be :success
    assigns(:groups).should.not.be nil
    template.should.be "dt/groups/index"
  end

  #When looking at a list of groups:
  #  -  the group should show name, description, type, geographic location and interests
  specify "should show many groups" do
    login_as :tim
    do_get
    assert_select "div.projectInfo#?", /group-\d+/
  end

  specify "should show name, description, type" do
    login_as :tim
    do_get
  	assert_select "a", "Public Group"
  end

  specify "should not see non-public groups" do
    login_as :tim
    do_get
    assert_select "a", {:count=>0, :text=>"Private Group"}
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

  def do_get(options=nil)
    get :new, options
  end

  specify "should redirect to /login when not logged in" do
    do_get
    should.redirect dt_login_path()
  end

  specify "should get new" do
    login_as :tim
    do_get
    status.should.be :success
    template.should.be "dt/groups/new"
  end
  
  specify "should have a form for creation" do
    login_as :tim
    do_get
    should.select "form#groupform"
  end

  specify "should have a hidden project_id field when params[:project_id] is passed" do
    login_as :tim
    do_get(:project_id => 1)
    should.select "form#groupform input[type=hidden][name=project_id]"
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
#  x choose the sector/cause interest of the group
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types, :sectors
  
  setup do
    @controller = Dt::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  specify "should redirect to /login when not logged in" do
    create_group({}, false)
    should.redirect dt_login_path()
  end

  specify "should create group" do
    old_count = Group.count
    create_group
    Group.count.should.equal old_count+1
  end
  
  specify "should redirect after group creation" do
    create_group
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
  
  specify "should be able to create a group and automatically be added as a member of that group" do
    lambda {
      create_group
    }.should.change(Membership, :count)
    group = assigns(:group)
    group.memberships.size.should.equal 1
    group.memberships[0].membership_type.should.be Membership.founder
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
  
  def do_get(id=1)
    get :show, :id => id
  end

  specify "should not redirect when not logged in" do
    do_get
    should.not.redirect dt_login_path()
  end

  specify "should not redirect if group is private and you are not a member" do
    @group = Group.create(:name => 'test', :private => :true, :group_type_id => 1)
    do_get(@group.id)
    should.not.redirect
  end

  specify "should not show group nav if group if private and you are not a member" do
    login_as :quentin
    @group = Group.create(:name => 'test', :private => :true, :group_type_id => 1)
    do_get(@group.id)
    page.should.not.select ".pageNav"
  end

  specify "if an invitation exists, should show an accept/decline form" do
    @group = Group.create(:name => 'test', :private => :true, :group_type_id => 1)
    @group.memberships.create(:user_id => users(:tim).id, :membership_type => Membership.founder)
    @group.invitations.create(:user_id => users(:tim).id, :to_email => users(:quentin).email)
    login_as :quentin
    do_get(@group.id)
    page.should.select "#invitationaccept"
    page.should.select "#invitationdecline"
  end

  specify "should show group" do
    login_as :quentin
    do_get
    status.should.be :success
    template.should.be 'dt/groups/show'
  end

  specify "should load @membership" do
    login_as :quentin
    do_get
    assigns(:membership).should.not.be nil
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

  specify "should redirect to /dt/login when not logged in" do
    do_get
    should.redirect dt_login_path()
  end

  specify "should get edit" do
    login_as :quentin
    do_get
    status.should.be :success
    template.should.be 'dt/groups/edit'
  end
end

context "Dt::GroupsController handling PUT /dt/groups/1" do
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types, :sectors
  
  setup do
    @controller = Dt::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  specify "should redirect to /login when not logged in" do
    put :update, :id => 1, :group => { :name => 'new name' }
    should.redirect dt_login_path()
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
  
  specify "should redirect to /login when not logged in" do
    delete :destroy, :id => 1
    should.redirect dt_login_path
  end

  specify "should destroy group" do
    login_as :quentin
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
#  x not see "non-public" groups
#  - see a public groups' name & description
#  x create a group
#these will all allow a user to connect with people who share their interests
#
#When looking at a list of groups:
#  -  the group should show name, description, type, geographic location and interests
#
#As a group member, I should be able to:
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
#  - post group admin messages to the group
#  - add Projects to the "interested in" list
#  - remove Projects from the "interested in" list
#these will all allow a community to form through the group model
#
#As a group creator, I should:
#  x automatically be added as a member of the group
#  x should become an owner of the group you just added
#  
#Low priority stories:
#Group Accounts
#  - Corporate Accounts (an Encana account where Encana will match employee giving)
#Group Competition:
#  - Competing with other groups to raise funds (ie. an Encana employee group competing against a Talisman Group)
#  - Group admin would send a competitiion invite would be sent to another existing group (of any kind)
#  - Invite must be accepted for competition to begin...