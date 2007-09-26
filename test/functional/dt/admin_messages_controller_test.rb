require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/admin_messages_controller'

# Re-raise errors caught by the controller.
class Dt::AdminMessagesController; def rescue_action(e) raise e end; end

context "Dt::AdminMessagesController inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::AdminMessagesController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::AdminMessagesController #route_for" do
  setup do
    @controller = Dt::AdminMessagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @rs         = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/admin_messages', :group_id => 1 } to /dt/groups/1/admin_messages" do
    route_for(:controller => "dt/admin_messages", :group_id => 1 ).should == "/dt/groups/1/admin_messages"
  end

  specify "should map { :controller => 'dt/admin_messages', :action => 'new', :group_id => 1 } to /dt/groups/1/admin_messages/new" do
	  route_for(:controller => 'dt/admin_messages', :action => 'new', :group_id => 1 ).should == "/dt/groups/1/admin_messages/new"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end  
end

context "Dt::AdminMessagesController handling GET /dt/groups/1/admin_messages" do
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :admin_messages

  setup do
    @controller = Dt::AdminMessagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def do_get(group_id=1)
    get :index, :group_id => group_id
  end

  specify "should redirect to /login when not logged in" do
    do_get
    should.redirect dt_login_path()
  end

  specify "should have an index method" do
    Dt::AdminMessagesController.new.should.respond_to 'index'
  end

  specify "should render the index template" do
    login_as :quentin
    do_get
    template.should.be 'dt/admin_messages/index'    
  end 
  
  specify "should assign @recent_admin_messages" do
    login_as :tim
    do_get
    assigns(:recent_admin_messages).should.not.be.nil
  end

  specify "should render a list of recent admin_messages" do
    login_as :tim
    do_get
    assert_select "p", "You are all wonderful.", { :minimum=> 2 }      
    assert_select "ul>li#?", /admin_message-\d+/, { :minimum=> 2 }       
  end

end

#ADMIN MESSAGES STORIES
#=============
# As an admin, I should be able to:
# - Create a new admin message that is viewable by the group members
# - Edit existing admin messages
# - Delete existing admin messages

# As a member, I should be able to:
# x View the list of recent admin messages

#/dt/groups/1/admin_messages



