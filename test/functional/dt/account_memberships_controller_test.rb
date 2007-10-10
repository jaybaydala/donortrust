require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/account_memberships_controller'

# Re-raise errors caught by the controller.
class Dt::AccountMembershipsController; def rescue_action(e) raise e end; end

context "Dt::AccountMemberships inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::AccountMembershipsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::AccountMemberships #route_for" do
  use_controller Dt::AccountMembershipsController
  setup do
    @rs = ActionController::Routing::Routes
  end
  
  specify "should map { :controller => 'dt/account_memberships', :action => 'index', :account_id => 1 } to /dt/accounts/1/account_memberships" do
    route_for(:controller => "dt/account_memberships", :action => "index", :account_id => 1).should == "/dt/accounts/1/account_memberships"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::AccountMemberships %w(index destroy) should exist "do
  use_controller Dt::AccountMembershipsController
  specify "methods should exist" do
    %w( index destroy ).each do |m|
      @controller.methods.should.include m
    end
  end
end
context "Dt::AccountMemberships %w(show new create edit update) should not exist "do
  use_controller Dt::AccountMembershipsController
  specify "methods should not exist" do
    %w( show new create edit update ).each do |m|
      @controller.methods.should.not.include m
    end
  end
end

context "Dt::AccountMemberships index handling" do
  use_controller Dt::AccountMembershipsController
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types

  specify "should redirect if not logged_in" do
    get :index, :account_id => 1
    should.redirect
  end

  specify "should not redirect if logged_in" do
    login_as :quentin
    get :index, :account_id => users(:quentin).id
    should.not.redirect
  end

  specify "should assign @groups" do
    login_as :quentin
    get :index, :account_id => users(:quentin).id
    assigns(:groups).should.not.be nil
  end

  specify "should show list of current groups" do
    login_as :quentin
    get :index, :account_id => users(:quentin).id
    assert_select "div.projectInfo#?", /group-\d+/
  end
end
