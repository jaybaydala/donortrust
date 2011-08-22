require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/group_permissions_test_helper'
require 'dt/groups/memberships_controller'

# Re-raise errors caught by the controller.
class Dt::Groups::MembershipsController; def rescue_action(e) raise e end; end

context "Dt::Groups::Memberships inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::Groups::MembershipsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Groups::Memberships #route_for" do
  use_controller Dt::Groups::MembershipsController
  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/groups/memberships', :group_id => 1 } to /dt/groups/1/memberships" do
    route_for(:controller => "dt/groups/memberships").should == "/dt/groups/1/memberships"
  end
  
  specify "should map { :controller => 'dt/groups/memberships', :group_id => 1 , :action => 'new' } to /dt/groups/1/memberships/new" do
    route_for(:controller => "dt/groups/memberships", :action => "new").should == "/dt/groups/1/memberships/new"
  end

  specify "should map { :controller => 'dt/groups/memberships', :group_id => 1 , :action => 'create' } to /dt/groups/1/memberships" do
    route_for(:controller => "dt/groups/memberships", :action => "create").should == "/dt/groups/1/memberships"
  end

  specify "should map { :controller => 'dt/groups/memberships', :group_id => 1 , :action => 'edit', :id => 1 } to /dt/groups/1/memberships/1;edit" do
    route_for(:controller => "dt/groups/memberships", :action => "edit", :id => 1).should == "/dt/groups/1/memberships/1;edit"
  end

  specify "should map { :controller => 'dt/groups/memberships', :group_id => 1 , :action => 'update', :id => 1 } to /dt/groups/1/memberships/1" do
    route_for(:controller => "dt/groups/memberships", :action => "update", :id => 1).should == "/dt/groups/1/memberships/1"
  end

  specify "should map { :controller => 'dt/groups/memberships', :group_id => 1 , :action => 'destroy', :id => 1} to /dt/groups/1/memberships/1" do
    route_for(:controller => "dt/groups/memberships", :action => "destroy", :id => 1).should == "/dt/groups/1/memberships/1"
  end

  specify "should map { :controller => 'dt/groups/memberships', :group_id => 1, :id =>1, :action => 'promote'} to /dt/groups/1/memberships/1;promote" do
    route_for(:controller => "dt/groups/memberships", :id =>1, :action => 'promote').should == "/dt/groups/1/memberships/1;promote"
  end

  specify "should map { :controller => 'dt/groups/memberships', :group_id => 1, :id =>1, :action => 'demote'} to /dt/groups/1/memberships/1;demote" do
    route_for(:controller => "dt/groups/memberships", :id =>1, :action => 'demote').should == "/dt/groups/1/memberships/1;demote"
  end
  
  private 
  def route_for(options)
    @rs.generate options.merge(:group_id => 1)
  end  
end

context "Dt::Groups::MembershipsController handling GET /dt/groups/1/memberships" do
  use_controller Dt::Groups::MembershipsController
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
  
  def do_get(group_id=2)
    get :index, :group_id => group_id
  end

  specify "should not redirect when not logged in" do
    do_get(1)
    should.not.redirect
  end

  specify "should show all the members of a group" do
    login_as :tim
    do_get
    assigns(:memberships).should.not.be nil
    assigns(:membership).should.not.be nil
    template.should.be "dt/groups/memberships/index"
  end 

  specify "should display a remove link for a group admin" do
    login_as :quentin
    do_get(1)
    assigns(:memberships).each do |membership|
    	#assert_select("a[href=/dt/groups/1/memberships/#{membership.id}]#membership-remove-link-#{membership.id}") unless membership.founder?
    	assert_select("a[href=/dt/groups/1/memberships/#{membership.id}]#membership-remove-link-#{membership.id}", :text => "Remove") unless membership.admin?
    end
  end  

  specify "should display a Make Admin link for a member" do
    login_as :quentin
    do_get(1)
    assigns(:memberships).each do |membership|
    	assert_select("a[href=/dt/groups/1/memberships/#{membership.id};promote]#membership-make-admin-link-#{membership.id}", :text => "Make Admin") unless membership.admin?
    end
  end

  specify "should display a Remove Admin link for an admin" do
    login_as :quentin
    User.find(3).memberships.create(:group_id => 1, :membership_type => 2)
    Group.find(1).memberships(true)
    do_get(1)
    assigns(:memberships).each do |membership|
    	assert_select("a[href=/dt/groups/1/memberships/#{membership.id};demote]#membership-remove-admin-link-#{membership.id}", :text => "Remove Admin") if membership.admin? && !membership.founder?
    end
  end
end

context "Dt::Groups::MembershipsController handling create" do
  use_controller Dt::Groups::MembershipsController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper
  
  setup do
    setup_group_permissions
    @memberships.stubs(:build).returns(@member)
    @member.stubs(:save).returns(true)
  end
  
  specify "should redirect to /dt/login when not logged in" do
    create_membership
    should.redirect login_path()
  end

  specify "should redirect to group home when logged in" do
    login_as(nil)
    @memberships.expects(:build).returns(@member)
    create_membership
    should.redirect dt_group_path(1)
  end

  specify "should create membership" do
    login_as(nil)
    @group.expects(:memberships).returns(@memberships)
    @group.expects(:private?).times(2).returns(false)
    @memberships.expects(:build).returns(@member)
    @member.expects(:save).returns(true)
    create_membership
  end
  
  specify "should not be able to become a member of a private group" do
    login_as(nil)
    @group.expects(:private?).times(2).returns(true)
    @member.expects(:save).never
    create_membership
  end

  specify "attempting to join a private group should redirect to the groups index" do
    login_as(nil)
    @group.expects(:private?).times(2).returns(true)
    @member.expects(:save).never
    create_membership
    should.redirect dt_groups_path
  end
  
  def create_membership
    post :create, :group_id => @group.to_param
  end  
end

context "Dt::Groups::MembershipsController handling PUT /dt/groups/1/memberships/1;promote" do
  use_controller Dt::Groups::MembershipsController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper

  setup do
    setup_group_permissions
  end

  specify "shouldn't be able to promote if !logged_in" do
    put :promote, :group_id => @group.id, :id => @member.id
    response.should.redirect login_path
  end
  
  specify "a founder should be able to promote a member to admin" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@founder)
    @memberships.expects(:find).with("2").returns(@member)
    @member.expects(:update_attributes).with(:membership_type => Membership.admin).returns(true)
    @member.stubs(:user).returns(@current_user)
    put :promote, :group_id => @group.id, :id => "2"
  end
  specify "an admin should be able to promote a member to admin" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@admin)
    @memberships.expects(:find).with("2").returns(@member)
    @member.expects(:update_attributes).with(:membership_type => Membership.admin).returns(true)
    @member.stubs(:user).returns(@current_user)
    put :promote, :group_id => @group.id, :id => "2"
  end
  specify "an admin should not be able to \"promote\" a founder to admin" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@admin)
    @memberships.expects(:find).with("2").returns(@founder)
    @founder.expects(:update_attributes).never
    @founder.stubs(:user).returns(@current_user)
    put :promote, :group_id => @group.id, :id => "2"
  end
  
  specify "a non-admin should not be able to promote a member to admin" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @memberships.expects(:find).with("2").never
    @member.expects(:update_attributes).never
    put :promote, :group_id => @group.id, :id => "2"
  end
end

context "Dt::Groups::MembershipsController handling PUT /dt/groups/1/memberships/1;demote" do
  use_controller Dt::Groups::MembershipsController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper
  
  setup do
    setup_group_permissions
  end

  specify "shouldn't be able to demote if !logged_in" do
    put :demote, :group_id => @group.id, :id => @member.id
    response.should.redirect login_path
  end
  
  specify "a founder should be able to demote an admin to member" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@founder)
    @memberships.expects(:find).with("2").returns(@member)
    @member.expects(:update_attributes).with(:membership_type => Membership.member).returns(true)
    @member.stubs(:user).returns(@current_user)
    put :demote, :group_id => @group.id, :id => "2"
  end
  specify "an admin should be able to demote an admin to member" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@admin)
    @memberships.expects(:find).with("2").returns(@member)
    @member.expects(:update_attributes).with(:membership_type => Membership.member).returns(true)
    @member.stubs(:user).returns(@current_user)
    put :demote, :group_id => @group.id, :id => "2"
  end
  specify "an admin should not be able to demote a founder to member" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@admin)
    @memberships.expects(:find).with("2").returns(@founder)
    @founder.expects(:update_attributes).never
    @founder.stubs(:user).returns(@current_user)
    put :demote, :group_id => @group.id, :id => "2"
  end
  
  specify "a non-admin should not be able to demote an admin to member" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @memberships.expects(:find).with("2").never
    @member.expects(:update_attributes).never
    put :demote, :group_id => @group.id, :id => "2"
  end
end 

context "Dt::Groups::MembershipsController handling DELETE /dt/groups/1/membership/1" do
  use_controller Dt::Groups::MembershipsController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper
  
  setup do
    setup_group_permissions
  end
  
  specify "should be able to leave a group" do
    login_as(nil)
    @memberships.expects(:find).with("2").returns(@member)
    @member.expects(:destroy).returns(true)
    @member.expects(:user).at_least_once.returns(@current_user)
    delete :destroy, :group_id => @group.to_param, :id => "2"
  end

  specify "as a member, you should not be able to remove another member" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @member2 = stub("member2", :id => 1000, :member? => true, :admin? => false, :founder? => false, :save => true)
    @member2.expects(:user).at_least_once.returns(stub("user", :id => @current_user.id + 100, :name => "sample user"))
    @memberships.expects(:find).with("2").returns(@member2)
    @member2.expects(:destroy).never
    delete :destroy, :group_id => @group.to_param, :id => "2"
    should.redirect dt_memberships_path(@group)
  end

  specify "as an admin, you should be able to remove another member" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@admin)
    @memberships.expects(:find).with("2").returns(@member)
    @member.expects(:user).at_least_once.returns(stub("user", :id => @current_user.id + 100, :name => "sample user"))
    @member.expects(:destroy).returns(true)
    delete :destroy, :group_id => @group.to_param, :id => "2"
    should.redirect dt_memberships_path(@group)
  end

  specify "as an founder, you should be able to remove another member" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@founder)
    @memberships.expects(:find).with("2").returns(@member)
    @member.expects(:user).at_least_once.returns(stub("user", :id => @current_user.id + 100, :name => "sample user"))
    @member.expects(:destroy).returns(true)
    delete :destroy, :group_id => @group.to_param, :id => "2"
    should.redirect dt_memberships_path(@group)
  end

  specify "as a founder, you should be able to remove an admin" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@founder)
    @memberships.expects(:find).with("2").returns(@admin)
    @admin.expects(:user).at_least_once.returns(stub("user", :id => @current_user.id + 100, :name => "sample user"))
    @admin.expects(:destroy).returns(true)
    delete :destroy, :group_id => @group.to_param, :id => "2"
    should.redirect dt_memberships_path(@group)
  end

  specify "as an admin, you should not be able to remove a founder" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@admin)
    @memberships.expects(:find).with("2").returns(@founder)
    @founder.expects(:destroy).never
    @founder.expects(:user).at_least_once.returns(stub("user", :id => @current_user.id + 100, :name => "sample user"))
    delete :destroy, :group_id => @group.to_param, :id => "2"
    should.redirect dt_memberships_path(@group)
  end
end
