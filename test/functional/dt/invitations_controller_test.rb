require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/invitations_controller'

# Re-raise errors caught by the controller.
class Dt::InvitationsController; def rescue_action(e) raise e end; end

context "Dt::Invitations inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::InvitationsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Invitations #route_for" do
  use_controller Dt::InvitationsController

  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/invitations', :action => 'index', :group_id => 1 } to /dt/groups/1/invitations" do
    route_for(:controller => "dt/invitations", :action => "index", :group_id => 1).should == "/dt/groups/1/invitations"
  end

  specify "should map { :controller => 'dt/invitations', :action => 'new', :group_id => 1 } to /dt/groups/1/invitations/new" do
    route_for(:controller => "dt/invitations", :action => "new", :group_id => 1).should == "/dt/groups/1/invitations/new"
  end

  specify "should map { :controller => 'dt/invitations', :action => 'create', :group_id => 1 } to /dt/groups/1/invitations" do
    route_for(:controller => "dt/invitations", :action => "create", :group_id => 1).should == "/dt/groups/1/invitations"
  end

  specify "should map { :controller => 'dt/invitations', :action => 'edit', :id => 1, :group_id => 1 } to /dt/groups/1/invitations/1;edit" do
    route_for(:controller => "dt/invitations", :action => "edit", :id => 1, :group_id => 1).should == "/dt/groups/1/invitations/1;edit"
  end

  specify "should map { :controller => 'dt/invitations', :action => 'update', :id => 1, :group_id => 1 } to /dt/groups/1/invitations/1" do
    route_for(:controller => "dt/invitations", :action => "update", :id => 1, :group_id => 1).should == "/dt/groups/1/invitations/1"
  end

  specify "should map { :controller => 'dt/invitations', :action => 'show', :id => 1, :group_id => 1 } to /dt/groups/1/invitations/1" do
    route_for(:controller => "dt/invitations", :action => "show", :id => 1, :group_id => 1).should == "/dt/groups/1/invitations/1"
  end

  specify "should map { :controller => 'dt/invitations', :action => 'destroy', :id => 1, :group_id => 1} to /dt/groups/1/invitations/1" do
    route_for(:controller => "dt/invitations", :action => "destroy", :id => 1, :group_id => 1).should == "/dt/groups/1/invitations/1"
  end

  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Invitations handling GET /dt/invitations;new" do
  use_controller Dt::InvitationsController
  fixtures :users, :groups, :invitations
  include DtAuthenticatedTestHelper
  
  specify "should redirect to login if !logged_in" do
    get :new, :group_id => 1
    should.redirect dt_login_path
  end
end

context "Dt::Invitations handling POST /dt/invitations" do
  use_controller Dt::InvitationsController
  fixtures :users, :groups, :memberships, :invitations
  include DtAuthenticatedTestHelper
  
  specify "should redirect to login if !logged_in" do
    i = invitation_params
    post :create, :group_id => i[:group_id], :invitation => i
    should.redirect dt_login_path
  end

  specify "should create an invitation" do
    lambda {
      u = users(:quentin)
      login_as :quentin
      i = invitation_params(:group_id => 1, :user_id => u.id)
      post :create, :group_id => i[:group_id], :invitation => i, :to_emails => 'tim@example.com'
    }.should.change(Invitation, :count)
  end

  specify "should redirect to group memberships" do
    u = users(:quentin)
    login_as :quentin
    i = invitation_params(:group_id => 1, :user_id => u.id)
    post :create, :group_id => i[:group_id], :invitation => i, :to_emails => 'tim@example.com'
    should.redirect dt_memberships_path(:group_id => i[:group_id])
  end

  specify "should take multiple to_emails" do
    Invitation.should.differ(:count).by(3) {
      u = users(:quentin)
      login_as :quentin
      i = invitation_params(:group_id => 1, :user_id => u.id)
      post :create, :group_id => i[:group_id], :invitation => i, :to_emails => 'tim@example.com,jay@example.com, des@example.com'
    }
    Invitation.should.differ(:count).by(3) {
      u = users(:quentin)
      login_as :quentin
      i = invitation_params(:group_id => 1, :user_id => u.id)
      post :create, :group_id => i[:group_id], :invitation => i, :to_emails => %w(tim@example.com jay@example.com des@example.com)
    }
  end

  specify "should return bogus to_emails in an error" do
    Invitation.should.differ(:count).by(0) {
      u = users(:quentin)
      login_as :quentin
      i = invitation_params(:group_id => 1, :user_id => u.id)
      post :create, :group_id => i[:group_id], :invitation => i, :to_emails => 'tim@examplecom,jayexample.com,desexamplecom'
      flash[:error].should =~ /could not be created for/
      flash[:error].should =~ /tim\@examplecom/
      flash[:error].should =~ /jayexample\.com/
      flash[:error].should =~ /desexamplecom/
    }
  end

  specify "should include an error message if the group is private and the user isn't an admin" do
    u = users(:quentin)
    login_as :quentin
    i = invitation_params(:group_id => 2, :user_id => u.id)
    post :create, :group_id => i[:group_id], :invitation => i, :to_emails => 'tim@example.com'
    flash[:error].should.equal 'Access denied'
    should.redirect dt_group_path(i[:group_id])
  end
  
  specify "should send an email for each valid to_email" do
    # for testing action mailer
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @emails = ActionMailer::Base.deliveries 
    @emails.clear
    @emails.should.differ(:length).by(3) {
      u = users(:quentin)
      login_as :quentin
      i = invitation_params(:group_id => 1, :user_id => u.id)
      post :create, :group_id => i[:group_id], :invitation => i, :to_emails => %w(tim@example.com jay@example.com des@example.com)
    }
  end

  protected
  def invitation_params(options = {})
    {:group_id => 1, :user_id => 1}.merge(options)
  end
end

context "Dt::Invitations handling PUT /dt/invitations" do
  use_controller Dt::InvitationsController
  fixtures :users, :groups, :memberships, :invitations
  include DtAuthenticatedTestHelper
  
  specify "should redirect to login if !logged_in" do
    do_update(create_invitation)
    should.redirect dt_login_path
  end

  specify "should error if logged_in, group is private and no invitations match your email/login" do
    login_as(:quentin)
    u = users(:quentin)
    u.memberships.clear
    invitation = create_invitation(:group_id => 2, :user_id => users(:tim).id)
    do_update(invitation)
    flash[:error].should.equal 'Access denied'
  end

  specify "should accept the invitation and redirect" do
    login_as(:quentin)
    u = users(:quentin)
    u.memberships.clear
    invitation = create_invitation(:group_id => 2, :to_email => u.email, :user_id => users(:tim).id)
    do_update(invitation)
    assigns(:invitation).accepted?.should.be true
    should.redirect dt_group_path(:id => invitation.group_id)
  end

  specify "should decline the invitation and redirect" do
    login_as(:quentin)
    u = users(:quentin)
    u.memberships.clear
    invitation = create_invitation(:group_id => 2, :to_email => u.email, :user_id => users(:tim).id)
    do_update(invitation, false)
    assigns(:invitation).accepted?.should.be false
    should.redirect dt_group_path(:id => invitation.group_id)
  end

  specify "should create a new membership on acceptance" do
    Membership.should.differ(:count).by(1) {
      login_as(:quentin)
      u = users(:quentin)
      u.memberships.clear
      invitation = create_invitation(:group_id => 2, :to_email => u.email, :user_id => users(:tim).id)
      do_update(invitation)
    }
  end

  protected
  def do_update(invitation, accepted = true)
    put :update, :group_id => invitation.group_id, :id => invitation.id, :accepted => accepted
  end
  def create_invitation(options={})
    Invitation.create({:group_id => 1, :user_id => 1, :to_email => 'tim@example.com'}.merge(options))
  end
end