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

  specify "should map { :controller => 'dt/accounts', :action => 'logout'} to /dt/accounts;logout" do
    route_for(:controller => "dt/accounts", :action => "logout").should == "/dt/accounts;logout"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'activate'} to /dt/accounts;activate" do
    route_for(:controller => "dt/accounts", :action => "activate").should == "/dt/accounts;activate"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'activate', :id => 'code' } to /dt/accounts;activate?id=code" do
    route_for(:controller => "dt/accounts", :action => "activate", :id => 'code' ).should == "/dt/accounts;activate?id=code"
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
      post :create, :user => { :login => 'quire@example.com', :first_name => 'Quire', :last_name => 'Tester', :display_name => 'Quirey', :password => 'quire', :password_confirmation => 'quire' }.merge(options)
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

context "Dt::Accounts handling GET /dt/accounts;activate" do
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    @controller = Dt::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  specify "should activate user" do
    User.authenticate('aaron@example.com', 'test').should.be.nil
    get :activate, :id => users(:aaron).activation_code
    users(:aaron).should.equal User.authenticate('aaron@example.com', 'test')
  end
end

context "Dt::Accounts user authentication mailer" do
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    @controller = Dt::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    # for testing action mailer
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @emails = ActionMailer::Base.deliveries 
    @emails.clear
  end

  specify "should activate user and send activation email" do
    get :activate, :id => users(:aaron).activation_code
    @emails.length.should.equal 1
    @emails.first.subject.should =~ /Your account has been activated/
    @emails.first.body.should    =~ /#{assigns(:user).name}, your account has been activated/
  end

  specify "should send activation email after signup" do
    create_user
    @emails.length.should.equal 1
    @emails.first.subject.should =~ /Please activate your new account/
    @emails.first.body.should    =~ /Username: quire@example/
    @emails.first.body.should    =~ /Password: quire/
    @emails.first.body.should    =~ /dt\/accounts;activate\?id=#{assigns(:user).activation_code}/
  end

  protected
  def create_user(options = {})
    post :create, :user => { :login => 'quire@example.com', :first_name => 'Quire', :last_name => 'Tester', :display_name => 'Quirey', :password => 'quire', :password_confirmation => 'quire' }.merge(options)
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

context "Dt::Accounts handling POST /dt/accounts/create" do
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    @controller = Dt::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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

  protected
  def create_user(options = {})
    post :create, :user => { :login => 'quire@example.com', :first_name => 'Quire', :last_name => 'Tester', :display_name => 'Quirey', :password => 'quire', :password_confirmation => 'quire' }.merge(options)
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
    page.should.select "input#user_login"
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
  
  specify "form should have an old_password, password and password_confirmation fields" do
    login_as :quentin
    do_get
    page.should.select "form#user_form input[name=old_password]"
    page.should.select "input#user_password"
    page.should.select "input#user_password_confirmation"
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

  specify "should allow a password change" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :old_password => 'test', :user => {:password => 'new_password', :password_confirmation => 'new_password' } }
    u.crypted_password.should.not.equal User.find(1).crypted_password
  end

  specify "non-matching passwords should not change" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :old_password => 'test', :user => {:password => 'new_password', :password_confirmation => 'another_password' } }
    u.crypted_password.should.equal User.find(1).crypted_password
  end

  specify "empty old_password should not change password" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :user => {:password => 'new_password', :password_confirmation => 'new_password' } }
    u.crypted_password.should.equal User.find(1).crypted_password
  end

  specify "incorrect old_password should not change password" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :old_password => 'incorrect_password', :user => {:password => 'new_password', :password_confirmation => 'new_password' } }
    u.crypted_password.should.equal User.find(1).crypted_password
  end
end


#In the context of an unauthenticated account:
#  - I have the option to resend the authentication email
#
#As a donor I need to be edit my profile so others can see my info, etc:
#  - if I change my email, it should be re-authenticated
#
#As a user I want to be able to retrieve my password so I won't forget it:
#  - creates a new password
#  - sends email to user's email address with new password
#  - on login, required to change the password to something rememberable
#