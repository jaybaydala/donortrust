require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/group_permissions_test_helper'
require 'dt/groups/news_controller'

module GroupNewsTestHelper
  def should_redirect_if_member
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    do_get
    should.redirect dt_group_path(@group)
  end
  
  def should_not_redirect_if_admin
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@admin)
    do_get
    should.not.redirect
  end
  
  def setup_group_news
    @group.stubs(:news).returns(@news)
    @group.stubs(:new_record?).returns(false)
    @memberships.stubs(:find_by_user_id).returns(@member)
  end
  
  def setup_single_group_news_stubs
    @group_news = GroupNews.new(:user_id => 1)
    @group_news.stubs(:id).returns(1)
    @group_news.stubs(:to_param).returns("1")
    @group_news.stubs(:new_record?).returns(false)
    @news = mock("group-news-collection")
    @news.stubs(:find).returns(@group_news)
    setup_group_news
  end

  def setup_many_group_news_stubs
    @group_messages = []
    (1..4).each do |i|
      group_news = GroupNews.new(:user_id => 1)
      group_news.stubs(:id).returns(1)
      group_news.stubs(:to_param).returns("1")
      group_news.stubs(:new_record?).returns(false)
      @group_messages << group_news
    end
    @news = mock("group-news-collection")
    @news.stubs(:find).returns(@group_messages)
    setup_group_news
  end
end


# Re-raise errors caught by the controller.
class Dt::Groups::NewsController; def rescue_action(e) raise e end; end

context "Dt::GroupNewsController inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::Groups::NewsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Groups::NewsController #route_for" do
  use_controller Dt::Groups::NewsController
  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/groups/news', :group_id => 1 } to /dt/groups/1/messages" do
    route_for(:controller => "dt/groups/news", :group_id => 1 ).should == "/dt/groups/1/messages"
  end

  specify "should map { :controller => 'dt/groups/news', :action => 'new', :group_id => 1 } to /dt/groups/1/messages/new" do
	  route_for(:controller => 'dt/groups/news', :action => 'new', :group_id => 1 ).should == "/dt/groups/1/messages/new"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end  
end

context "Dt::Groups::NewsController handling GET /dt/groups/1/messages" do
  use_controller Dt::Groups::NewsController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupNewsTestHelper
  
  setup do
    setup_group_permissions
    setup_many_group_news_stubs
    @group_messages.each{|message| message.stubs(:user).returns(User.new(:first_name => "Mocked", :last_name => "User"))}
    @news.stubs(:paginate).returns(@group_messages.paginate(:per_page => 5))
  end
  
  def do_get
    get :index, :group_id => @group.to_param
  end

  specify "should redirect to /login when not logged in and @group.private?" do
    @group.expects(:private?).returns(true)
    do_get
    should.redirect dt_login_path()
  end

  specify "should not redirect unless @group.private?" do
    @group.expects(:private?).returns(false)
    do_get
    should.not.redirect
  end
  
  specify "should not redirect if @group.private? and @membership.member?" do
    login_as
    @group.expects(:private?).returns(true)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    do_get
    should.not.redirect
  end

  specify "should render the index template" do
    login_as
    do_get
    template.should.be 'dt/groups/news/index'    
  end 
  
  specify "should assign @group_news" do
    login_as
    do_get
    assigns(:group_news).should.not.be.nil
  end
  
  specify "should paginate @group_news" do
    @news = mock("news")
    @news.expects(:paginate).with({:page => nil, :per_page => 5, :order => "created_at DESC"}).returns(@group_messages.paginate(:per_page => 5))
    @group.expects(:news).returns(@news)
    login_as
    do_get
  end

  specify "should render a list of recent group_news" do
    login_as
    @group_messages.map! do |message|
      message.stubs(:message?).returns(true)
      message.stubs(:message).returns("You are all wonderful")
      message.stubs(:user).returns(@current_user)
      message
    end
    do_get
  end
end

context "Dt::Groups::NewsController handling GET /dt/groups/1/messages/new" do
  use_controller Dt::Groups::NewsController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupNewsTestHelper
  
  setup do
    setup_group_permissions
    news = stub("news", :build => GroupNews.new)
    @group.stubs(:news).returns(news)
  end
  
  def do_get
    get :new, :group_id => @group.to_param
  end
  
  specify "should redirect if member?" do
    should_redirect_if_member
  end

  specify "should not redirect if admin?" do
    should_not_redirect_if_admin
  end
end

context "Dt::Groups::NewsController handling GET /dt/groups/1/messages/edit/1" do
  use_controller Dt::Groups::NewsController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupNewsTestHelper
  
  setup do
    setup_group_permissions
    @group_news = GroupNews.new(:user_id => 1)
    @group_news.stubs(:id).returns(1)
    @group_news.stubs(:to_param).returns("1")
    @group_news.stubs(:new_record?).returns(false)
    @news = mock("group-news-collection")
    @news.stubs(:find).returns(@group_news)
    @group.stubs(:news).returns(@news)
    @memberships.stubs(:find_by_user_id).returns(@admin)
  end
  
  def do_get
    get :edit, :id => 1, :group_id => @group.to_param
  end
  
  specify "should redirect if member?" do
    should_redirect_if_member
  end

  specify "should not redirect if admin? == @current_user" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@admin)
    @admin.expects(:user_id).returns(@current_user.id)
    do_get
    should.not.redirect
  end

  specify "should not redirect if founder?" do
    login_as(nil)
    @memberships.stubs(:find_by_user_id).returns(@founder)
    @memberships.expects(:find_by_user_id).returns(@founder)
    do_get
    should.not.redirect
  end

  specify "should assign @group_news" do
    login_as(nil)
    @memberships.stubs(:find_by_user_id).returns(@admin)
    do_get
    assigns(:group_news).should.not.be nil
  end
end

context "Dt::Groups::NewsController handling POST /dt/groups/1/messages" do
  use_controller Dt::Groups::NewsController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupNewsTestHelper
  
  setup do
    setup_group_permissions
    @group_news = GroupNews.new
    news = stub("news", :build => @group_news)
    @group.stubs(:news).returns(news)
  end
  
  def do_valid_post
    @group_news.expects(:save).returns(true)
    do_post
  end
  def do_invalid_post
    @group_news.expects(:save).returns(false)
    do_post
  end
  def do_post
    post :create, :group_id => @group.to_param, :group_news => {}
  end
  
  specify "should redirect before save unless admin?" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @group_news.expects(:save).never
    do_post
    should.redirect dt_group_path(@group)
  end

  specify "should @save if admin?" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@admin)
    do_valid_post
  end

  specify "should redirect on valid post" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@admin)
    do_valid_post
    should.redirect dt_group_path(@group)
  end

  specify "should show new template on invalid post" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@admin)
    do_invalid_post
    template.should.be "dt/groups/news/new"
  end
end

context "Dt::Groups::NewsController handling PUT /dt/groups/1/messages/1" do
  use_controller Dt::Groups::NewsController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupNewsTestHelper
  
  setup do
    setup_group_permissions
    setup_single_group_news_stubs
    @member.stubs(:admin?).returns(true)
  end
  
  def do_valid_put
    @group_news.expects(:update_attributes).returns(true)
    do_put
  end

  def do_invalid_put
    @group_news.expects(:update_attributes).returns(false)
    do_put
  end
  
  def do_put
    put :update, {:id => "1", :group_id => @group.to_param, :group_news => {}}
  end
  
  specify "should redirect if member?" do
    login_as(nil)
    @member.expects(:admin?).returns(false)
    do_put
    should.redirect dt_group_path(@group)
  end

  specify "should assign @group_news" do
    login_as(nil)
    @memberships.stubs(:find_by_user_id).returns(@admin)
    do_put
    assigns(:group_news).should.not.be nil
  end
  
  specify "should update_attributes if admin? == @current_user" do
    login_as(nil)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @member.expects(:user_id).returns(@current_user.id)
    @group_news.expects(:update_attributes).returns(true)
    do_put
  end

  specify "should update_attributes if founder?" do
    login_as(nil)
    @member.expects(:founder?).returns(true)
    @memberships.stubs(:find_by_user_id).returns(@member)
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @group_news.expects(:update_attributes).returns(true)
    do_put
  end

  specify "should redirect to group home on success" do
    login_as
    @memberships.stubs(:find_by_user_id).returns(@member)
    @member.expects(:user_id).returns(@current_user.id)
    do_valid_put
    should.redirect dt_group_path(@group)
  end
  
  specify "should render edit template when not successful" do
    login_as
    @memberships.stubs(:find_by_user_id).returns(@member)
    @member.stubs(:user_id).returns(@current_user.id)
    do_invalid_put
    template.should.be "dt/groups/news/edit"
  end
end

context "Dt::Groups::NewsController handling DELETE /dt/groups/1/messages/1" do
  use_controller Dt::Groups::NewsController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupNewsTestHelper

  setup do
    setup_group_permissions
    setup_single_group_news_stubs
    @member.stubs(:admin?).returns(true)
  end

  specify "should not destroy if !admin?" do
    login_as(nil)
    @member.expects(:admin?).returns(false)
    @group_news.expects(:destroy).never
    do_delete
    should.redirect dt_group_path(@group)
  end

  specify "should not destroy if admin? but not the message owner" do
    login_as(nil)
    @member.expects(:admin?).returns(true)
    @member.expects(:user_id).returns(@current_user.id)
    @group_news.expects(:user_id).returns(@current_user.id + 1)
    @group_news.expects(:destroy).never
    do_delete
    should.redirect dt_group_path(@group)
  end

  specify "should destroy if admin? and the message owner" do
    login_as(nil)
    @member.expects(:admin?).returns(true)
    @member.expects(:user_id).returns(@current_user.id)
    @group_news.expects(:user_id).returns(@current_user.id)
    @group_news.expects(:destroy).returns(true)
    do_delete
    flash[:notice].should.not.be.nil
    should.redirect dt_messages_path(@group)
  end

  specify "should destroy if founder? and not the message owner" do
    login_as(nil)
    @member.expects(:founder?).returns(true)
    @member.expects(:user_id).never
    @group_news.expects(:user_id).never
    @group_news.expects(:destroy).returns(true)
    do_delete
    flash[:notice].should.not.be.nil
    should.redirect dt_messages_path(@group)
  end
  
  def do_delete
    delete :destroy, :group_id => @group.to_param, :id => "1"
  end
end

