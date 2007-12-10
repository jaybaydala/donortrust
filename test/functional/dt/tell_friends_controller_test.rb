require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/tell_friends_controller'

# Re-raise errors caught by the controller.
class Dt::TellFriendsController; def rescue_action(e) raise e end; end

context "Dt::TellFriends inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::TellFriendsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::TellFriends #route_for" do
  use_controller Dt::TellFriendsController
  setup do
    @rs = ActionController::Routing::Routes
  end
  
  specify "should map { :controller => 'dt/tell_friends', :action => 'index' } to /dt/tell_friends" do
    route_for(:controller => "dt/tell_friends", :action => "index").should == "/dt/tell_friends"
  end
  
  specify "should map { :controller => 'dt/tell_friends', :action => 'show', :id => 1 } to /dt/tell_friends/1" do
    route_for(:controller => "dt/tell_friends", :action => "show", :id => 1).should == "/dt/tell_friends/1"
  end
  
  specify "should map { :controller => 'dt/tell_friends', :action => 'new' } to /dt/tell_friends/new" do
    route_for(:controller => "dt/tell_friends", :action => "new").should == "/dt/tell_friends/new"
  end
  
  specify "should map { :controller => 'dt/tell_friends', :action => 'create' } to /dt/tell_friends" do
    route_for(:controller => "dt/tell_friends", :action => "create").should == "/dt/tell_friends"
  end
    
  specify "should map { :controller => 'dt/tell_friends', :action => 'confirm'} to /dt/tell_friends/1" do
    route_for(:controller => "dt/tell_friends", :action => "confirm").should == "/dt/tell_friends;confirm"
  end

  specify "should map { :controller => 'dt/tell_friends', :action => 'preview'} to /dt/tell_friends;preview" do
    route_for(:controller => "dt/tell_friends", :action => "preview").should == "/dt/tell_friends;preview"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::TellFriends new, create, confirm and preview should exist "do
  use_controller Dt::TellFriendsController
  specify "methods should exist" do
    %w( new create confirm preview ).each do |m|
      @controller.methods.should.include m
    end
  end
end

context "Dt::TellFriends index behaviour"do
  use_controller Dt::TellFriendsController
  fixtures :users
  include DtAuthenticatedTestHelper

  specify "index should redirect to new" do
    get :index
    should.redirect :action => 'new'
  end

 specify "index should redirect to new when logged_in?" do
    login_as :quentin
    get :index
    should.redirect :action => 'new'
  end
end

context "Dt::TellFriends new behaviour"do
  use_controller Dt::TellFriendsController
  fixtures :users
  include DtAuthenticatedTestHelper
  
  specify "should not redirect whether you're logged_in? or not" do
    get :new
    should.not.redirect
    login_as :quentin
    get :new
    should.not.redirect
  end

  specify "should assign the dt/ecards javascript to @action_js" do
    get :new
    assigns(:action_js).should.equal 'dt/ecards'
  end

  specify "should show form#tellfriendform with the appropriate attributes" do
    get :new
    page.should.select "form[action=/dt/tell_friends;confirm][method=post]#tellfriendform"
  end

  specify "should assign @ecards" do
    get :new
    assigns(:ecards).class.should.be Array
    assigns(:ecards).each do |ecard|
      ecard.class.should.be ECard
    end
  end

  specify "form output should always contain to_name, to_email, credit_card, card_expiry fields, comments" do
    # !logged_in?
    get :new
    inputs = %w( input#share_name input#share_email input#share_email_confirmation input#share_to_name 
                 input#share_to_email input#share_to_email_confirmation textarea#share_message )
    assert_select "#tellfriendform" do
      inputs.each do |selector|
        assert_select selector
      end
    end
    # logged_in?
    login_as :quentin
    get :new
    assert_select "#tellfriendform" do
      inputs.each do |selector|
        assert_select selector
      end
    end
  end

  specify "output should contain input#share_name and input#share_email" do
    get :new
    page.should.select "#tellfriendform input#share_name"
    page.should.select "#tellfriendform input#share_email"
    login_as :quentin
    get :new
    page.should.select "#tellfriendform input#share_name"
    page.should.select "#tellfriendform input#share_email"
  end

  specify "if project_id is passed, should show the project" do
    get :new, :project_id => 1
    page.should.select "#tellfriendform input[type=radio][value=1]#share_project_id_1"
  end

  specify "if project_id is not passed, should suggest giving a project" do
    get :new
    page.should.select "#tellfriendform #projectsuggest a[href=/dt/projects]"
  end
  
  specify  "should contain a preview submit button" do
    get :new
    page.should.select "#ecardPreview"
  end

end


context "Dt::TellFriends preview behaviour"do
  use_controller Dt::TellFriendsController
  fixtures :users
  include DtAuthenticatedTestHelper
  
  specify 'should have @tell_friend and @tell_friend_mail in the assigns' do
    do_get
    assigns(:share).should.not.be.nil
    assigns(:share_mail).should.not.be.nil
  end

  specify 'should use dt/tell_friends/preview template' do
    do_get
    template.should.be 'dt/tell_friends/preview'
  end
  
  private
  def do_get(options={})
    share_params = { 
      :project_id => 1, 
      :name => 'Tim Glen', 
      :email => 'timglen@pivotib.com', 
      :to_name => 'Curtis', 
      :to_email => 'curtis@pivotib.com', 
      :message => 'Hello World!',
      }
    
    # merge with passed options
    share_params.merge!(options[:share]) if options[:share] != nil
    options.delete(:share) if options[:share] != nil
    
    get :preview, { :share => share_params }.merge(options)
  end
end

context "Dt::TellFriends confirm behaviour"do
  use_controller Dt::TellFriendsController
  fixtures :e_cards, :users, :projects
  include DtAuthenticatedTestHelper
  
  specify "should show confirm template on a post with login" do
    do_post
    template.should.be "dt/tell_friends/confirm"
  end

  specify "should show confirm template on a post without login" do
    do_post( {}, false )
    template.should.be "dt/tell_friends/confirm"
  end

  specify "form should post to create action" do
    do_post
    assert_select "form[method=post][action=/dt/tell_friends]#tellfriendform"
  end

  specify "form output should always contain name, email, to_name, to_email, message fields" do
    inputs = %w( input#share_name input#share_email input#share_to_name input#share_to_email input#share_message )
    # !logged_in?
    do_post
    assert_select "#tellfriendform" do
      inputs.each do |selector|
        assert_select selector
      end
    end
    # logged_in?
    do_post( {}, false )
    assert_select "#tellfriendform" do
      inputs.each do |selector|
        assert_select selector
      end
    end
  end

  specify "form output should include project_id field when params[:project_id] is passed" do
    do_post( :project_id => 1 )
    assert_select "#tellfriendform input[type=hidden]#share_project_id"
  end

  specify "form should use new template if we don't include to_email, email" do
    tell_friend_params = {}
    fields = %w( to_email email ).each {|f| 
      do_post({ :share => {f.to_sym => nil} })
      template.should.be 'dt/tell_friends/new'
    }
  end

  specify "should trim mailto: from the start of to_email and email fields" do
    do_post( :share => {:to_email => 'mailto: curtis@example.com', :email => 'mailto:  tim@example.com'} )
    share = assigns(:share)
    share[:to_email].should == 'curtis@example.com'
    share[:email].should == 'tim@example.com'
  end
  
  protected
  def do_post(options={}, login = true)
    login_as :quentin if login == true
    share_params = { 
      :project_id => 1, 
      :name => 'Tim Glen', 
      :email => 'timglen@pivotib.com', 
      :to_name => 'Curtis', 
      :to_email => 'curtis@pivotib.com', 
      :message => 'Hello World!',
      }
    share_params[:user_id] = users(:quentin).id if login == true
    
    # merge with passed options
    share_params.merge!(options[:share]) if options[:share] != nil
    options.delete(:share) if options[:share] != nil
    
    post :confirm, { :share => share_params}.merge(options)
  end
end

context "Dt::TellFriends create behaviour"do
  use_controller Dt::TellFriendsController
  fixtures :users, :projects
  include DtAuthenticatedTestHelper
  
  specify "should create a share and render the create template" do
    # !logged_in?
    lambda {
      create_tell_friend(nil, false)
      template.should.be "dt/tell_friends/create"
    }.should.change(Share, :count)
    # logged_in?
    lambda {
      create_tell_friend()
      template.should.be "dt/tell_friends/create"
    }.should.change(Share, :count)
  end

  specify "@tell_friend should be assigned on create" do
    create_tell_friend()
    assigns(:share).should.not.be.nil
  end
  
  protected
  def create_tell_friend(options={}, login = true)
    login_as :quentin if login == true
    share_params = { 
      :name => 'Tim Glen', 
      :email => 'timglen@pivotib.com', 
      :to_name => 'Curtis', 
      :to_email => 'curtis@pivotib.com', 
      :message => 'Hello World!', 
      :e_card_id => 1
      }
    share_params[:user_id] = users(:quentin).id if login == true
    
    # merge with passed options
    share_params.merge!(options) if options != nil
    
    post :create, { :share => share_params }
  end
end

context "Dt::TellFriends show, edit, update and destroy should not exist" do
  use_controller Dt::TellFriendsController
  specify "method should not exist" do
    %w( edit update destroy ).each do |m|
      @controller.methods.should.not.include m
    end
  end
end
