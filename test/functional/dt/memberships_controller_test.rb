require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/memberships_controller'

# Re-raise errors caught by the controller.
class Dt::MembershipsController; def rescue_action(e) raise e end; end

context "Dt::Memberships inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::MembershipsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Memberships #route_for" do
  use_controller Dt::MembershipsController
  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/memberships', :group_id => 1 } to /dt/memberships" do
    route_for(:controller => "dt/memberships").should == "/dt/groups/1/memberships"
  end
  
  specify "should map { :controller => 'dt/memberships', :group_id => 1 , :action => 'edit', :id => 1 } to /dt/memberships/1;edit" do
    route_for(:controller => "dt/memberships", :action => "edit", :id => 1).should == "/dt/groups/1/memberships/1;edit"
  end

  specify "should map { :controller => 'dt/memberships', :group_id => 1 , :action => 'destroy', :id => 1} to /dt/memberships/1" do
    route_for(:controller => "dt/memberships", :action => "destroy", :id => 1).should == "/dt/groups/1/memberships/1"
  end

  specify "should map { :controller => 'dt/memberships', :group_id => 1, :id =>1, :action => 'promote'} to /dt/groups/1/memberships/1;promote" do
    route_for(:controller => "dt/memberships", :id =>1, :action => 'promote').should == "/dt/groups/1/memberships/1;promote"
  end

  specify "should map { :controller => 'dt/memberships', :group_id => 1, :id =>1, :action => 'demote'} to /dt/groups/1/memberships/1;demote" do
    route_for(:controller => "dt/memberships", :id =>1, :action => 'demote').should == "/dt/groups/1/memberships/1;demote"
  end
  
  private 
  def route_for(options)
    @rs.generate options.merge(:group_id => 1)
  end  
end

context "Dt::MembershipsController handling GET /dt/groups/1/memberships" do
  use_controller Dt::MembershipsController
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
  
  def do_get(group_id=2)
    get :index, :group_id => group_id
  end

  specify "should not redirect not logged in" do
    do_get(1)
    should.not.redirect
  end

  specify "should show all the members of a group" do
    login_as :tim
    do_get
    assigns(:memberships).should.not.be nil
    assigns(:membership).should.not.be nil
    template.should.be "dt/memberships/index"
  end 

  xspecify "should display a remove link for a group admin" do
    login_as :quentin
    do_get(1)
    assigns(:memberships).each do |membership|
    	#assert_select("a[href=/dt/groups/1/memberships/#{membership.id}]#membership-remove-link-#{membership.id}") unless membership.founder?
    	assert_select("a[href=/dt/groups/1/memberships/#{membership.id}]") unless membership.founder?
    end
  end  

  xspecify "should display a select to give/take admin status" do
    login_as :quentin
    do_get(1)
    assigns(:memberships).each do |membership|
    	assert_select "select#membership_#{membership.id}_membership_type" if membership.id != users(:quentin).id
    end
  end  

end

context "Dt::MembershipsController handling create" do
  use_controller Dt::MembershipsController
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types

  specify "should redirect to /dt/login when not logged in" do
    create_membership(false)
    should.redirect dt_login_path()
  end
  
  specify "should redirect when logged in" do
    create_membership
    should.redirect dt_group_path(1)
  end

  specify "should be able to create membership" do
    old_count = Membership.count
    create_membership
    Membership.count.should.equal old_count+1
  end

  specify "should not be able to become a member of a private group" do
    old_count = Membership.count
    create_membership(true, 2)
    Membership.count.should.equal old_count
  end

  specify "attempting to join a private group should redirect to the groups index" do
    create_membership(true, 2)
    should.redirect dt_groups_path
  end
  
  def create_membership( login = true, group_id = 1)
    login_as :tim if login == true
    post :create, :group_id => group_id
  end  
end

context "Dt::MembershipsController handling PUT /dt/memberships/1;promote, /dt/memberships/1;demote" do
  use_controller Dt::MembershipsController
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
    
  specify "should be able to bestow group admin status to a current member" do
    login_as :tim
    put :promote, :id => 3, :group_id => 1
    m = Membership.find(3)
    m.membership_type.should.equal 2
  end

  specify "should be able to revoke group admin status from a current member" do
    login_as :tim
    put :demote, :id => 5, :group_id => 1
    m = Membership.find 5
    m.membership_type.should.equal 1
  end
  
  #As a group founder, I
  specify "should be protected from other admins removing my admin status" do
    login_as :aaron #Admin of the group about to be used
    id = 4 #membership id of with Owner status
    put :demote, :id => id, :group_id => 1
    m = Membership.find(id) 
    m.admin?.should.be true

    login_as :tim #Owner
    id = 5 #membership id of with admin status
    put :demote, :id => id, :group_id => 1
    m = Membership.find(id)
    m.admin?.should.be false  
  end  
end 

context "Dt::MembershipsController handling DELETE /dt/membership/1" do
  use_controller Dt::MembershipsController
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types

  specify "should be able to withdraw membership from a group" do
    login_as :quentin
    old_count = Membership.count
    delete :destroy, {:controller => 'dt/memberships', :id => 1, :group_id => 1 }
    do_delete
    Membership.count.should.equal old_count-1    
  end

  def do_delete(id=1)
  end
end

#MEMBER STORIES
#=============
#As a user, I should be able to:
#JA do we need to see all the groups cuurent_user is a member of?
#  x see all the groups I am a member of 
#  
#  x become a member of a public group
#  x not become a member of a non-public group
#  x become a member of a non-public group to which i've been invited
#As a group member, I should be able to:
#  x withdraw membership from a group
#As a group-admin, I should be able to:
#  x make a current member a group admin
#  x remove admin status from another group-admin
#As a group creator, I should:
#  x be protected from other admins removing my admin status
