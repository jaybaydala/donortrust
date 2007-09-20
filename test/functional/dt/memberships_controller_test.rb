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
  setup do
    @controller = Dt::MembershipsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @rs         = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/memberships' } to /dt/memberships" do
    route_for(:controller => "dt/memberships").should == "/dt/memberships"
  end
  
  specify "should map { :controller => 'dt/memberships', :action => :join, :group_id => 1 } to /dt/groups/1/memberships/new;join" do
	  route_for(:controller => "dt/memberships", :action => :join, :group_id => 1 ).should == "/dt/groups/1/memberships/new;join"
  end

  specify "should map { :controller => 'dt/memberships', :action => 'edit', :id => 1 } to /dt/membershipss/1;edit" do
    route_for(:controller => "dt/memberships", :action => "edit", :id => 1).should == "/dt/memberships/1;edit"
  end

  specify "should map { :controller => 'dt/memberships', :action => 'bestow', :id => 1 } to /dt/memberships/1;bestow" do
    route_for(:controller => "dt/memberships", :action => "bestow", :id => 1).should == "/dt/memberships/1;bestow"
  end
  
  specify "should map { :controller => 'dt/memberships', :action => 'destroy', :id => 1} to /dt/memberships/1" do
    route_for(:controller => "dt/memberships", :action => "destroy", :id => 1).should == "/dt/memberships/1"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end  
end

context "Dt::MembershipsController handling POST join" do
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types
  
  setup do
    @controller = Dt::MembershipsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  specify "should redirect to /dt/accounts;signin when not logged in" do
    create_membership(false)
    should.redirect dt_login_path()
  end

  specify "should be able to create membership" do
    old_count = Membership.count
    create_membership
    Membership.count.should.equal old_count+1
  end

  specify "should not be able to become a member of a non-public group" do
    old_count = Membership.count
    create_membership(true, 2)
    Membership.count.should.equal old_count
  end
  
  specify "should be able to withdraw membership from a group" do
    login_as :tim
    old_count = Membership.count    
    delete :destroy, {:controller => 'dt/memberships', :id => 1}
    Membership.count.should.equal old_count-1    
  end
    
  #specify "should be able to bestow group admin status to a current member" do
    #login_as :tim
    #post :bestow, {:controller => 'dt/memberships', :id => 1 }
    #m = Membership.find 1
    #m.membership_type.should.equal 2
  #end
  
  def create_membership( login = true, group_id = 1)
    login_as :tim if login == true
    put :join, :group_id => group_id
  end  
end


#MEMBER STORIES
#=============
#As a user, I should be able to:
#JA- see all the groups I am a member of 
#  x become a member of a public group
#  x not become a member of a non-public group
#  x become a member of a non-public group to which i've been invited
#As a group member, I should be able to:
#  x withdraw membership from a group
#As a group-admin, I should be able to:
#  x make a current member a group admin
#  - remove admin status from another group-admin
