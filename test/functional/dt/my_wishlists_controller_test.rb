require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/my_wishlists_controller'

# Re-raise errors caught by the controller.
class Dt::MyWishlistsController; def rescue_action(e) raise e end; end

context "Dt::MyWishlists inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::MyWishlistsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::MyWishlists #route_for" do
  use_controller Dt::MyWishlistsController

  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/my_wishlists', :action => 'index', :account_id => 1 } to /dt/accounts/1/my_wishlists" do
    route_for(:controller => "dt/my_wishlists", :action => "index", :account_id => 1).should == "/dt/accounts/1/my_wishlists"
  end

  specify "should map { :controller => 'dt/my_wishlists', :action => 'new', :account_id => 1 } to /dt/accounts/1/my_wishlists/new" do
    route_for(:controller => "dt/my_wishlists", :action => "new", :account_id => 1).should == "/dt/accounts/1/my_wishlists/new"
  end

  specify "should map { :controller => 'dt/my_wishlists', :action => 'create', :account_id => 1 } to /dt/accounts/1/my_wishlists" do
    route_for(:controller => "dt/my_wishlists", :action => "create", :account_id => 1).should == "/dt/accounts/1/my_wishlists"
  end

  specify "should map { :controller => 'dt/my_wishlists', :action => 'show', :id => 1, :account_id => 1 } to /dt/accounts/1/my_wishlists/1" do
    route_for(:controller => "dt/my_wishlists", :action => "show", :id => 1, :account_id => 1).should == "/dt/accounts/1/my_wishlists/1"
  end

  specify "should map { :controller => 'dt/my_wishlists', :action => 'destroy', :id => 1, :account_id => 1} to /dt/accounts/1/my_wishlists/1" do
    route_for(:controller => "dt/my_wishlists", :action => "destroy", :id => 1, :account_id => 1).should == "/dt/accounts/1/my_wishlists/1"
  end

  specify "should map { :controller => 'dt/my_wishlists', :action => 'new_message', :account_id => 1} to /dt/accounts/1/my_wishlists;new_message" do
    route_for(:controller => "dt/my_wishlists", :action => "new_message", :account_id => 1).should == "/dt/accounts/1/my_wishlists;new_message"
  end

  specify "should map { :controller => 'dt/my_wishlists', :action => 'confirm', :account_id => 1} to /dt/accounts/1/my_wishlists;confirm" do
    route_for(:controller => "dt/my_wishlists", :action => "confirm", :account_id => 1).should == "/dt/accounts/1/my_wishlists;confirm"
  end

  specify "should map { :controller => 'dt/my_wishlists', :action => 'preview', :account_id => 1} to /dt/accounts/1/my_wishlists;preview" do
    route_for(:controller => "dt/my_wishlists", :action => "preview", :account_id => 1).should == "/dt/accounts/1/my_wishlists;preview"
  end

  specify "should map { :controller => 'dt/my_wishlists', :action => 'send_message', :account_id => 1} to /dt/accounts/1/my_wishlists;send_message" do
    route_for(:controller => "dt/my_wishlists", :action => "send_message", :account_id => 1).should == "/dt/accounts/1/my_wishlists;send_message"
  end

  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::MyWishlists handling GET /dt/my_wishlists" do
  use_controller Dt::MyWishlistsController
  fixtures :users, :projects
  include DtAuthenticatedTestHelper
  
  specify "should redirect to login if !logged_in" do
    get :index
    should.redirect login_path
  end

  specify "should redirect to account index if logged_in" do
    login_as(:quentin)
    get :index, :account_id => users(:quentin).id
    should.redirect dt_account_path(users(:quentin).id)
  end
end

context "Dt::MyWishlists handling GET /dt/my_wishlists;new" do
  use_controller Dt::MyWishlistsController
  fixtures :users, :projects
  include DtAuthenticatedTestHelper
  
  specify "should redirect to login if !logged_in" do
    do_get
    should.redirect login_path
  end

  specify "should not redirect to login if logged_in" do
    login_as :quentin
    do_get(users(:quentin))
    should.not.redirect
  end
  
  specify "if !params[:project_id] should give a link back to projects" do
    login_as :quentin
    do_get(users(:quentin), nil)
    assigns(:project).should.be nil
    page.should.select "a[href=/dt/projects]"
  end

  specify "if params[:project_id] should assign @project" do
    login_as :quentin
    do_get(users(:quentin))
    assigns(:project).class.should.be Project
  end
  
  specify "should contain a create form with project_id hidden field" do
    login_as :quentin
    do_get(users(:quentin))
    assert_select "form[action=/dt/accounts/#{users(:quentin).id}/my_wishlists][method=post]" do
      assert_select "input[type=hidden][name=project_id][value=1]"
    end
  end
  
  specify "should not allow a user into another users wishlist" do
    login_as :quentin
    do_get(users(:tim))
    should.redirect
  end
  
  protected
  def do_get(user=nil, project_id=1)
    user_id = user ? user.id : nil
    get :new, :account_id=>user_id, :project_id=>project_id
  end
end

context "Dt::MyWishlists handling POST /dt/my_wishlists" do
  use_controller Dt::MyWishlistsController
  fixtures :users
  include DtAuthenticatedTestHelper

  specify "should get redirected if !logged_in?" do
    do_post
    response.should.redirect login_path
  end
  
  specify "should not allow a user into another users wishlist" do
    login_as :quentin
    do_post(users(:tim))
    should.redirect
  end

  specify "should add a project" do
    login_as :quentin
    old_count = users(:quentin).projects.size
    do_post(users(:quentin))
    MyWishlist.count(:conditions => {:user_id =>users(:quentin)}).should.equal old_count+1
  end
  
  protected
  def do_post(user=nil, project_id = 1)
    user_id = user ? user.id : nil
    post :create, :account_id => user_id, :project_id => project_id
  end
end

context "Dt::MyWishlists handling DELETE /dt/my_wishlists" do
  use_controller Dt::MyWishlistsController
  fixtures :users
  include DtAuthenticatedTestHelper

  specify "should get redirected if !logged_in?" do
    do_delete
    response.should.redirect login_path
  end

  specify "should not allow a user into another users wishlist" do
    login_as :quentin
    do_delete(users(:tim))
    should.redirect
  end
  
  specify "should delete a wishlist" do
    login_as :quentin
    do_post(users(:quentin))
    users(:quentin).projects.size.should.equal 1
    do_delete(users(:quentin), MyWishlist.find(:first, :conditions => {:user_id =>users(:quentin)}))
    users(:quentin).projects(true).size.should.equal 0
  end

  protected
  def do_post(user=nil, project_id = 1)
    user_id = user ? user.id : nil
    post :create, :account_id => user_id, :project_id => project_id
  end
  def do_delete(user=nil, id = 1)
    user_id = user ? user.id : nil
    delete :destroy, :account_id => user_id, :id => id
  end
end

context "Dt::MyWishlists handling GET /dt/my_wishlists;new_message" do
  use_controller Dt::MyWishlistsController
  fixtures :users, :e_cards
  include DtAuthenticatedTestHelper

  specify "should not allow a user into another users wishlist" do
    login_as :quentin
    do_get(users(:tim))
    should.redirect
  end
  
  specify "should assign the dt/ecards javascript to @action_js" do
    login_as :quentin
    do_get(users(:quentin))
    assigns(:action_js).should.equal 'dt/ecards'
  end

  specify "should assign @ecards" do
    login_as :quentin
    do_get(users(:quentin))
    assigns(:ecards).class.should.be Array
    assigns(:ecards).each do |ecard|
      ecard.class.should.be ECard
    end
  end
  
  specify "should show form#mywishlistform with the appropriate attributes" do
    login_as :quentin
    do_get(users(:quentin))
    page.should.select "form[action=/dt/accounts/1/my_wishlists;confirm][method=post]#mywishlistform"
  end

  specify "form output should contain to_name, to_email, credit_card, card_expiry fields, comments" do
    # !logged_in?
    login_as :quentin
    do_get(users(:quentin))
    inputs = %w( input#share_name input#share_email input#share_email_confirmation input#share_to_name 
                 input#share_to_email input#share_to_email_confirmation textarea#share_message )
    assert_select "#mywishlistform" do
      inputs.each do |selector|
        assert_select selector
      end
    end
  end

  specify "output should contain input#share_name and input#share_email" do
    login_as :quentin
    do_get(users(:quentin))
    page.should.select "#mywishlistform input#share_name"
    page.should.select "#mywishlistform input#share_email"
  end

  specify "should contain a preview submit button" do
    login_as :quentin
    do_get(users(:quentin))
    page.should.select "#ecardPreview"
  end

  specify "should contain a project_ids[] checkbox" do
    login_as :quentin
    do_post(users(:quentin), 1)
    do_post(users(:quentin), 2)
    do_get(users(:quentin))
    page.should.select "#mywishlistform input[type=checkbox]", 2
  end
  
  protected
  def do_get(user=nil)
    user_id = user ? user.id : nil
    get :new_message, :account_id => user_id
  end
  def do_post(user=nil, project_id = 1)
    user_id = user ? user.id : nil
    post :create, :account_id => user_id, :project_id => project_id
  end
end

context "Dt::MyWishlists preview behaviour" do
  use_controller Dt::MyWishlistsController
  fixtures :users
  include DtAuthenticatedTestHelper
  
  specify 'should have @share and @share_mail in the assigns' do
    login_as :quentin
    do_get()
    assigns(:share).should.not.be.nil
    assigns(:share_mail).should.not.be.nil
  end

  specify 'should use dt/my_wishlists/preview template' do
    login_as :quentin
    do_get
    template.should.be 'dt/my_wishlists/preview'
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
    project_ids = [1, 2]
    
    # merge with passed options
    share_params.merge!(options[:share]) if options[:share] != nil
    options.delete(:share) if options[:share] != nil
    
    get :preview, { :account_id => 1, :share => share_params, :project_ids => project_ids }.merge(options)
  end
end

context "Dt::MyWishlists confirm behaviour" do
  use_controller Dt::MyWishlistsController
  fixtures :e_cards, :users, :projects
  include DtAuthenticatedTestHelper
  
  specify "should show confirm template on a post with login" do
    do_post
    template.should.be "dt/my_wishlists/confirm"
  end

  specify "form should post to create action" do
    do_post
    assert_select "form[method=post][action=/dt/accounts/1/my_wishlists;send_message]#wishlistform"
  end

  specify "form output should always contain name, email, to_name, to_email, message fields" do
    inputs = %w( input#share_name input#share_email input#share_to_name input#share_to_email input#share_message )
    # !logged_in?
    do_post
    assert_select "#wishlistform" do
      inputs.each do |selector|
        assert_select selector
      end
    end
  end

  specify "form output should include project_ids fields" do
    do_post()
    assert_select "#wishlistform" do
      assigns(:projects).each do |project|
        assert_select "input[type=hidden][id=project_id-#{project.id}]", 1
      end
    end
  end

  specify "form should use new template if we don't include to_email, email" do
    my_wishlist_params = {}
    fields = %w( to_email email ).each {|f| 
      do_post({ :share => {f.to_sym => nil} })
      template.should.be 'dt/my_wishlists/new_message'
    }
  end

  specify "should show new_message template if no project_ids are passed" do
    do_post({}, true, nil)
    template.should.be "dt/my_wishlists/new_message"
  end

  specify "should have an error on the project_id field for the @share assign if no project_ids are passed" do
    do_post({}, true, nil)
    assigns(:share).errors.on_base.should.not.be.nil
  end

  protected
  def do_post(options={}, login = true, project_ids = [1, 2])
    login_as :quentin if login == true
    share_params = { 
      :wishlist => true, 
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
    
    post :confirm, { :account_id => 1, :share => share_params, :project_ids => project_ids }.merge(options)
  end
end

context "Dt::MyWishlists create behaviour" do
  use_controller Dt::MyWishlistsController
  fixtures :users, :projects
  include DtAuthenticatedTestHelper
  
  specify "should create a share and render the create template" do
    # logged_in?
    lambda {
      send_message
      template.should.be "dt/my_wishlists/send_message"
    }.should.change(Share, :count)
  end

  specify "@tell_friend should be assigned on create" do
    send_message
    assigns(:share).should.not.be.nil
  end
  
  protected
  def send_message(options={}, login = true)
    login_as :quentin if login == true
    share_params = { 
      :name => 'Tim Glen', 
      :email => 'timglen@pivotib.com', 
      :to_name => 'Curtis', 
      :to_email => 'curtis@pivotib.com', 
      :message => 'Hello World!', 
      :e_card_id => 1,
      :wishlist => true
      }
    share_params[:user_id] = users(:quentin).id if login == true
    project_ids = [1,2]
    
    # merge with passed options
    share_params.merge!(options) if options != nil
    
    post :send_message, { :account_id => users(:quentin).id, :project_ids => project_ids, :share => share_params }
  end
end