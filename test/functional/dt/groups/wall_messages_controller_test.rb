require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/group_permissions_test_helper'
require 'dt/groups/wall_messages_controller'


module GroupWallMessagesTestHelper
  def setup_group_wall_messages
    @wall_message = GroupWallMessage.new
    @wall_messages = stub_everything("wall_messages_collection")
    @wall_messages.stubs(:find).returns(@wall_message)
    messages = (1000..1002).map do |i|
      message = GroupWallMessage.new
      message.stubs(:id).returns(i)
    end
    messages = messages.paginate
    messages.map! do |message| 
      message.stubs(:message?).returns(true)
      message.stubs(:message).returns("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
      message.stubs(:created_at?).returns(true)
      message.stubs(:created_at).returns(5.minutes.ago)
      user = stub_everything("user", :id => 2000, :name => 'Mocked User')
      message.stubs(:user).returns(user)
      message.stubs(:user_id).returns(user.id)
      message
    end
    @wall_messages.stubs(:paginate).returns(messages)
    @wall_messages.stubs(:build).returns(@wall_message)
    @group.stubs(:wall_messages).returns(@wall_messages)
  end
end

include DtAuthenticatedTestHelper, GroupPermissionsTestHelper

# Re-raise errors caught by the controller.
class Dt::Groups::WallMessagesController; def rescue_action(e) raise e end; end

context "Dt::Groups::WallMessagesController inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::Groups::WallMessagesController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Groups::WallMessagesController #route_for" do
  use_controller Dt::Groups::WallMessagesController
  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/groups/wall_messages', :group_id => 1 } to /dt/groups/1/wall_messages" do
    route_for(:controller => "dt/groups/wall_messages", :group_id => 1 ).should == "/dt/groups/1/wall_messages"
  end

  specify "should map { :controller => 'dt/groups/wall_messages', :action => 'new', :group_id => 1 } to /dt/groups/1/wall_messages/new" do
	  route_for(:controller => 'dt/groups/wall_messages', :action => 'new', :group_id => 1 ).should == "/dt/groups/1/wall_messages/new"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end  
end

context "WallMessagesController handling GET /" do
  use_controller Dt::Groups::WallMessagesController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupWallMessagesTestHelper
  setup do
    setup_group_permissions
    setup_group_wall_messages
  end

  def do_request
    get :index, :group_id => @group.id
  end
  
  specify "should redirect if group.private?" do
    @group.expects(:private?).returns(true)
    do_request
    response.should.redirect dt_login_path
  end
  
  specify "should not redirect if group.private? and current_user is a member" do
    login_as
    @group.expects(:private?).returns(true)
    @memberships.expects(:find_by_user_id).at_least_once.with(@current_user.id).returns(@member)
    do_request
    response.should.not.redirect
  end
  
  specify "should not redirect if !group.private?" do
    @group.expects(:private?).returns(false)
    do_request
    response.should.not.redirect
  end
end

context "WallMessagesController handling GET /1" do
  use_controller Dt::Groups::WallMessagesController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupWallMessagesTestHelper
  setup do
    setup_group_permissions
    setup_group_wall_messages
    @wall_message.stubs(:id).returns(1000)
    @wall_message.stubs(:user_id).returns(1)
  end
  
  def do_request
    get :show, :group_id => @group.id, :id => 1
  end
  
  specify "should redirect if group.private?" do
    @group.expects(:private?).returns(true)
    do_request
    response.should.redirect dt_login_path
  end
  
  specify "should not redirect if group.private? and current_user is a member" do
    login_as
    @group.expects(:private?).returns(true)
    @memberships.expects(:find_by_user_id).at_least_once.with(@current_user.id).returns(@member)
    do_request
    response.should.not.redirect
  end

  specify "should not redirect if !group.private?" do
    @group.expects(:private?).returns(false)
    do_request
    response.should.not.redirect
  end
end

context "WallMessagesController handling GET /1/new" do
  use_controller Dt::Groups::WallMessagesController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupWallMessagesTestHelper
  setup do
    setup_group_permissions
    setup_group_wall_messages
  end
  
  def do_request
    get :new, :group_id => @group.id
  end
  
  specify "should redirect if group.private?" do
    @group.expects(:private?).returns(true)
    do_request
    response.should.redirect dt_login_path
  end

  specify "should redirect if current_user is not a member" do
    login_as
    @memberships.expects(:find_by_user_id).at_least_once.with(@current_user.id).returns(false)
    do_request
    response.should.redirect dt_group_path(@group)
  end

  specify "should not redirect if current_user is a member" do
    login_as
    @memberships.expects(:find_by_user_id).at_least_once.with(@current_user.id).returns(@member)
    do_request
    response.should.not.redirect
  end
end

context "WallMessagesController handling POST /" do
  use_controller Dt::Groups::WallMessagesController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupWallMessagesTestHelper
  setup do
    setup_group_permissions
    setup_group_wall_messages
  end
  
  def do_request
    post :create, :group_id => @group.id
  end
  
  specify "should not save if group.private?" do
    login_as
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(false)
    @group.expects(:private?).returns(true)
    @wall_message.expects(:save).never
    do_request
    response.should.redirect dt_group_path(@group)
  end

  specify "should not save if current_user is not a member" do
    login_as
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(false)
    @wall_message.expects(:save).never
    do_request
    response.should.redirect dt_group_path(@group)
  end
  
  specify "should not save if current_user is not a member" do
    login_as
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(false)
    @wall_message.expects(:save).never
    do_request
  end

  specify "should save if current_user is a member" do
    login_as
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @wall_message.expects(:save).returns(true)
    do_request
  end

  specify "should add a flash[:notice] if save" do
    login_as
    @wall_message.expects(:save).returns(true)
    do_request
    flash[:notice].should.not.be.nil
  end
end

context "WallMessagesController handling GET /1/edit" do
  use_controller Dt::Groups::WallMessagesController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupWallMessagesTestHelper
  setup do
    setup_group_permissions
    setup_group_wall_messages
    @wall_message.stubs(:user_id).returns(1)
    @wall_message.stubs(:id).returns(1000)
  end

  def do_request
    get :edit, :group_id => @group.id, :id => 1
  end
  
  specify "should redirect if group.private?" do
    @group.expects(:private?).returns(true)
    do_request
    response.should.redirect dt_login_path
  end

  specify "should redirect if current_user is not a member" do
    login_as
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(false)
    do_request
    response.should.redirect dt_group_path(@group)
  end
  
  specify "should redirect if current_user is a member and doesn't own the wall post" do
    login_as
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @wall_message.expects(:user_id).returns(@current_user.id + 1)
    do_request
    response.should.redirect dt_group_path(@group)
  end

  specify "should not redirect if current_user is a member and owns the wall post" do
    login_as
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @wall_message.expects(:user_id).returns(@current_user.id)
    do_request
    response.should.not.redirect
  end
end

context "WallMessagesController handling PUT /1" do
  use_controller Dt::Groups::WallMessagesController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupWallMessagesTestHelper
  setup do
    setup_group_permissions
    setup_group_wall_messages
    @wall_message.stubs(:user_id).returns(1)
    @wall_message.stubs(:id).returns(1000)
  end
  
  def do_request
    put :update, :group_id => @group.id, :id => "1"
  end
  
  specify "should not save if group.private?" do
    @group.expects(:private?).returns(true)
    @wall_message.expects(:update_attributes).never
    do_request
    response.should.redirect dt_login_path
  end

  specify "should not save if current_user is not a member" do
    login_as
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(false)
    @wall_message.expects(:update_attributes).never
    do_request
    response.should.redirect dt_group_path(@group)
  end
  
  specify "should not save if current_user is a member and doesn't own the wall post" do
    login_as
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @wall_message.expects(:user_id).returns(@current_user.id + 1)
    @wall_message.expects(:update_attributes).never
    do_request
    response.should.redirect dt_group_path(@group)
  end

  specify "should render edit template if validation fails" do
    login_as
    @wall_messages.expects(:find).with("1").returns(@wall_message)
    @wall_message.expects(:update_attributes).returns(false)
    do_request
    template.should.be "dt/groups/wall_messages/edit"
  end

  specify "should save if current_user is a member and owns the wall post" do
    login_as
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @wall_message.expects(:user_id).returns(@current_user.id)
    @wall_message.expects(:update_attributes).returns(true)
    do_request
    response.should.redirect dt_group_path(@group)
  end

  specify "should add a flash[:notice] when update_attributes is successful" do
    login_as
    @memberships.expects(:find_by_user_id).with(@current_user.id).returns(@member)
    @wall_message.expects(:user_id).returns(@current_user.id)
    @wall_message.expects(:update_attributes).returns(true)
    do_request
    flash[:notice].should.not.be.nil
  end
end

context "WallMessagesController handling DELETE /1" do
  use_controller Dt::Groups::WallMessagesController
  include DtAuthenticatedTestHelper, GroupPermissionsTestHelper, GroupWallMessagesTestHelper
  setup do
    setup_group_permissions
    setup_group_wall_messages
  end
  
  def do_request
    delete :destroy, :group_id => @group.id, :id => 1
  end
  
  specify "should not destroy and should redirect to login if group.private?" do
    @group.expects(:private?).returns(true)
    @wall_message.expects(:destroy).never
    do_request
    response.should.redirect dt_login_path
  end

  specify "should destroy if current_user owns the wall post" do
    login_as
    @group.expects(:private?).returns(true)
    @memberships.expects(:find_by_user_id).at_least_once.with(@current_user.id).returns(@member)
    @wall_message.expects(:user_id).returns(@current_user.id)
    @wall_message.expects(:destroy).returns(true)
    do_request
    response.should.redirect dt_group_path(@group)
  end

  specify "should destroy if current_user is a group admin" do
    login_as
    @group.expects(:private?).returns(true)
    @memberships.expects(:find_by_user_id).at_least_once.with(@current_user.id).returns(@member)
    @member.expects(:admin?).returns(true)
    @wall_message.expects(:destroy).returns(true)
    do_request
    response.should.redirect dt_group_path(@group)
  end

  specify "should not destroy if current_user is not a member" do
    login_as
    @memberships.expects(:find_by_user_id).at_least_once.with(@current_user.id).returns(false)
    @wall_message.expects(:destroy).never
    do_request
    response.should.redirect dt_group_path(@group)
  end
end
