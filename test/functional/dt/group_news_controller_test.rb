require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/group_news_controller'

# Re-raise errors caught by the controller.
class Dt::GroupNewsController; def rescue_action(e) raise e end; end

context "Dt::GroupNewsController inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::GroupNewsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::GroupNewsController #route_for" do
  setup do
    @controller = Dt::GroupNewsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @rs         = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/group_news', :group_id => 1 } to /dt/groups/1/group_news" do
    route_for(:controller => "dt/group_news", :group_id => 1 ).should == "/dt/groups/1/group_news"
  end

  specify "should map { :controller => 'dt/group_news', :action => 'new', :group_id => 1 } to /dt/groups/1/group_news/new" do
	  route_for(:controller => 'dt/group_news', :action => 'new', :group_id => 1 ).should == "/dt/groups/1/group_news/new"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end  
end

context "Dt::GroupNewsController handling GET /dt/groups/1/group_news" do
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_news

  setup do
    @controller = Dt::GroupNewsController.new
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
    Dt::GroupNewsController.new.should.respond_to 'index'
  end

  specify "should render the index template" do
    login_as :quentin
    do_get
    template.should.be 'dt/group_news/index'    
  end 
  
  specify "should assign @recent_group_news" do
    login_as :tim
    do_get
    assigns(:recent_group_news).should.not.be.nil
  end

  specify "should render a list of recent group_news" do
    login_as :tim
    do_get
    assert_select "p", "You are all wonderful.", { :minimum=> 2 }      
    assert_select "ul>li#?", /group_news-\d+/, { :minimum=> 2 }       
  end

end

#GROUP NEWS STORIES
#=============
# As an admin, I should be able to:
# - Create a new group news message that is viewable by the group members
# - Edit existing group news messages
# - Delete existing group news messages

# As a member, I should be able to:
# x View the list of recent admin messages

#/dt/groups/1/group_news



