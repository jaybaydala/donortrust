require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/accounts_controller'
#require 'mocha'
require 'pp'

# Re-raise errors caught by the controller.
class Dt::AccountsController; def rescue_action(e) raise e end; end

context "Dt::Accounts inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::AccountsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Accounts #route_for" do
  setup do
    @controller = Dt::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @rs         = ActionController::Routing::Routes
  end

  specify "should recognize the routes" do
    @rs.generate(:controller => "dt/accounts", :action => "index").should.equal "/dt/accounts"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'index' } to /dt/accounts" do
    route_for(:controller => "dt/accounts", :action => "index").should == "/dt/accounts"
  end
  
  specify "should map { :controller => 'dt/accounts', :action => 'new' } to /dt/accounts/new" do
    route_for(:controller => "dt/accounts", :action => "new").should == "/dt/accounts/new"
  end
  
  specify "should map { :controller => 'dt/accounts', :action => 'show', :id => 1 } to /dt/accounts/1" do
    route_for(:controller => "dt/accounts", :action => "show", :id => 1).should == "/dt/accounts/1"
  end
  
  specify "should map { :controller => 'dt/accounts', :action => 'edit', :id => 1 } to /dt/accounts/1;edit" do
    route_for(:controller => "dt/accounts", :action => "edit", :id => 1).should == "/dt/accounts/1;edit"
  end
  
  specify "should map { :controller => 'dt/accounts', :action => 'update', :id => 1} to /dt/accounts/1" do
    route_for(:controller => "dt/accounts", :action => "update", :id => 1).should == "/dt/accounts/1"
  end
  
  specify "should map { :controller => 'dt/accounts', :action => 'destroy', :id => 1} to /dt/accounts/1" do
    route_for(:controller => "dt/accounts", :action => "destroy", :id => 1).should == "/dt/accounts/1"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'signin'} to /dt/accounts;signin" do
    route_for(:controller => "dt/accounts", :action => "signin").should == "/dt/accounts;signin"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'login'} to /dt/accounts;login" do
    route_for(:controller => "dt/accounts", :action => "login").should == "/dt/accounts;login"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'logout'} to /dt/accounts/;logout" do
    route_for(:controller => "dt/accounts", :action => "logout").should == "/dt/accounts;logout"
  end
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Accounts handling login and logout requests" do
  include DtAuthenticatedTestHelper
  fixtures :users

  setup do
    @controller = Dt::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  teardown do
  end

  specify "should login and redirect" do
    post :login, :login => 'quentin@example.com', :password => 'test'
    session[:user].should.not.be.nil
    should.redirect
  end

  specify "should fail login and not redirect" do
    post :login, :login => 'quentin@example.com', :password => 'bad password'
    session[:user].should.be.nil
    status.should.be :success
  end

  specify "should allow signup" do
    lambda {
      create_user
      should.redirect
    }.should.change(User, :count)
  end
 
  specify "should require login on signup" do
    lambda {
      create_user(:login => nil)
      assigns(:user).errors.on(:login).should.not.be.nil
      status.should.be :success
    }.should.not.change(User, :count)
  end

  specify "should require password on signup" do
    lambda {
      create_user(:password => nil)
      assigns(:user).errors.on(:password).should.not.be.nil
      status.should.be :success
    }.should.not.change(User, :count)
  end

  specify "should require password_confirmation on signup" do
    lambda {
      create_user(:password_confirmation => nil)
      assigns(:user).errors.on(:password_confirmation).should.not.be.nil
      status.should.be :success
    }.should.not.change(User, :count)
  end

  specify "should require valid email as login on signup" do
    lambda {
      create_user(:login => 'timglen')
      assigns(:user).errors.on(:login).should.not.be.nil
      status.should.be :success

      create_user(:login => 'timglen@pivotib')
      assigns(:user).errors.on(:login).should.not.be.nil
      status.should.be :success
      
      create_user(:login => '@pivotib.com')
      assigns(:user).errors.on(:login).should.not.be.nil
      status.should.be :success
      
      create_user(:login => 'pivotib.com')
      assigns(:user).errors.on(:login).should.not.be.nil
      status.should.be :success
    }.should.not.change(User, :count)
  end

  specify "should logout" do
    login_as :quentin
    get :logout
    session[:user].should.be.nil
    should.redirect
  end

  specify "should remember me" do
    post :login, :login => 'quentin@example.com', :password => 'test', :remember_me => "1"
    @response.cookies["auth_token"].should.not.be.nil
  end

  specify "should not remember_me" do
    post :login, :login => 'quentin@example.com', :password => 'test', :remember_me => "0"
    @response.cookies["auth_token"].should.be.nil
  end
  
  specify "should delete token on logout" do
    login_as :quentin
    get :logout
    @response.cookies["auth_token"].should.equal []
  end

  specify "should login with cookie" do
    users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    @controller.send(:logged_in?).should.be true
  end

  specify "should fail expired cookie login" do
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    @controller.send(:logged_in?).should.be false
  end

  specify "should fail cookie login" do
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :index
    @controller.send(:logged_in?).should.be false
  end

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
    
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end

context "Dt::Accounts handling GET /dt/accounts" do
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    @controller = Dt::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #User.stubs(:find).returns([@user])
  end
  
  def do_get
    get :index
  end
  
  specify "should get index if logged_in? or User.count > 0" do
    do_get
    response.should.not.redirect
    template.should.be "dt/accounts/index"
    User.destroy_all
    do_get
    response.should.redirect :action => 'new'
  end
end

context "Dt::Accounts handling GET /dt/accounts/signin" do
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    @controller = Dt::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def do_get
    get :signin
  end

  specify "should render dt/accounts/signin template if not logged_in?" do
    do_get
    template.should.be "dt/accounts/signin"
  end
  
  specify "should redirect if logged_in?" do
    login_as :quentin
    do_get
    should.redirect
  end

  specify "should have a form set to post to /dt/accounts;login" do
    do_get
    page.should.select "form[action=/dt/accounts;login][method=post]"
  end

end


context "Dt::Accounts handling GET /dt/accounts/new" do
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    @controller = Dt::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def do_get
    get :new
  end

  specify "should render dt/accounts/new template if not logged_in?" do
    do_get
    template.should.be "dt/accounts/new"
  end
  
  specify "should redirect if logged_in?" do
    login_as :quentin
    do_get
    should.redirect
  end

  specify "should have a form set to post to /dt/accounts" do
    do_get
    page.should.select "form[action=/dt/accounts][method=post]"
  end

end

context "Dt::Accounts handling GET /dt/accounts/1;edit" do
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    @controller = Dt::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #User.stubs(:find).returns([@user])
  end
  
  def do_get
    get :edit, :id => 1
  end
  
  specify "should redirect to signin if not logged in" do
    do_get
    should.redirect :action => 'signin'
  end

  specify "should redirect if trying to edit other than current_user" do
    login_as :aaron
    do_get
    should.redirect
  end

  specify "should render if trying to edit current_user" do
    login_as :quentin
    do_get
    should.not.redirect
    template.should.be "dt/accounts/edit"
  end

  specify "should render the form" do
    login_as :quentin
    do_get
    page.should.select "form#user_form"
    page.should.select "input#user_email"
    page.should.select "input#user_password"
    page.should.select "input#user_password_confirmation"
    page.should.select "input[type=submit]"
  end

  specify "should have a form set to put to /dt/accounts/1" do
    login_as :quentin
    do_get
    page.should.select "form[action=/dt/accounts/1]"
    assert_select "form#user_form" do
      assert_select "input[type=submit]"
    end
  end
end

context "Dt::Accounts handling PUT /dt/accounts/1;update" do
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    @controller = Dt::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #User.stubs(:find).returns([@user])
  end
  
  specify "should redirect to signin if not logged_in?" do
    @user = User.find(1)
    put :update, { :id => @user.id, :user => { :email => @user.email } }
    should.redirect_to :action => 'signin'
  end

  specify "should not redirect to signin if logged_in?" do
    login_as :quentin
    @user = User.find(1)
    put :update, { :id => @user.id, :user => { :first_name => 'Tim' } }
    should.redirect_to :action => 'index'
  end
  
  specify "should redirect to edit if not current_user" do
    login_as :quentin
    @user = User.find(2)
    put :update, { :id => @user.id , :user => { :first_name => 'Tim' } }
    should.redirect
  end

  specify "should update your user if logged in and you're the current user" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :user => { :first_name => 'Tim' } }
    u.first_name.should.not.equal User.find(1).first_name
    should.redirect_to :action => 'index'
  end
end


#  - Email should be authenticated through an emailed auth_code
#  - optional unique Display Name to be used if given. If not, First Name, Last Name are used for ident purposes
#    - add formnote to this effect
#    - either Display Name or First Name and Last Name are required at signup
#
#In the context of an unauthenticated account:
#  - I cannot login until I authenticate my email address
#  - I have the option to resend the authentication email
#
#As a donor I need to be edit my profile so others can see my info, etc:
#  - if I change my email, it should be re-authenticated
#  - Password changes require me to type in my old password
#  - New password needs to be confirmed/re-entered
#
#As a user I want to be able to retrieve my password so I won't forget it:
#  - creates a new password
#  - sends email to user's email address with new password
#  - on login, required to change the password to something rememberable
#