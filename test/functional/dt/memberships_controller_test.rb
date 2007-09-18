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

  specify "should create membership" do
    old_count = Membership.count
    create_membership
    Membership.count.should.equal old_count+1
  end
  
  def create_membership(login = true)
    login_as :tim if login == true
    put :join, :group_id => 1
  end
end


#MEMBER STORIES
#=============
#As a user, I should be able to:
#JA- see all the groups I am a member of 
#  x become a member of a public group
#  - not become a member of a non-public group
#  - become a member of a non-public group to which i've been invited
#As a group member, I should be able to:
#  - withdraw membership from a group
#As a group-admin, I should be able to:
#  - make a current member a group admin
#  - remove admin status from another group-admin
