require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/sessions_controller'

# Re-raise errors caught by the controller.
class Dt::SessionsController; def rescue_action(e) raise e end; end

context "Dt::Sessions inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::SessionsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Sessions US tax requests" do
  use_controller Dt::SessionsController
  include DtAuthenticatedTestHelper
  fixtures :users
  
  specify "should set requires_us_tax_receipt to true if user not logged in" do
    get :request_us_tax_receipt
    session[:requires_us_tax_receipt].should.be true
  end
  
  specify "should set requires_us_tax_receipt to true if user not logged in and redirect to login page" do
    get :request_us_tax_receipt
    should.redirect login_url
  end
  
  specify "should redirect to us tax page if user logged in" do
    login_as :quentin
    get :request_us_tax_receipt
    should.redirect GROUNDSPRING_URL
  end
  
  specify "should set requires_us_tax_receipt to nil if logging out user" do
    login_as :quentin
    get :request_us_tax_receipt
    get :destroy
    session[:requires_us_tax_receipt].should.be nil
  end
end

context "Dt::Accounts #route_for" do
  use_controller Dt::AccountsController

  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/sessions', :action => 'new' } to /dt/session/new" do
    route_for(:controller => "dt/sessions", :action => "new").should == "/dt/session/new"
  end

  specify "should map { :controller => 'dt/sessions', :action => 'create' } to /dt/session" do
    route_for(:controller => "dt/sessions", :action => "create").should == "/dt/session"
  end

  specify "should map { :controller => 'dt/sessions', :action => 'destroy' } to /dt/session" do
    route_for(:controller => "dt/sessions", :action => "destroy").should == "/dt/session"
  end

  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Sessions handling GET dt/session requests" do
  use_controller Dt::SessionsController
  include DtAuthenticatedTestHelper
  fixtures :users
  
  specify "should redirect_to dt_accounts_path unless logged_in?" do
    get :show
    should.redirect dt_accounts_path
  end

  specify "should redirect_to dt_accounts_path unless logged_in?" do
    login_as :quentin
    get :show
    should.redirect dt_account_path(users(:quentin))
  end
end

context "Dt::Sessions handling GET /dt/session/new" do
  use_controller Dt::SessionsController
  fixtures :users
  include DtAuthenticatedTestHelper

  def do_get
    get :new
  end

  specify "should render dt/sessions/new template if not logged_in?" do
    do_get
    template.should.be "dt/sessions/new"
  end
  
  specify "should redirect if logged_in?" do
    login_as :quentin
    do_get
    should.redirect
  end

  specify "should have a form set to post to /dt/sessions" do
    do_get
    page.should.select "form[action=/dt/session][method=post]"
  end
  
end

context "Dt::Sessions handling POST dt/session requests" do
  use_controller Dt::SessionsController
  include DtAuthenticatedTestHelper
  fixtures :users
  
  specify "should login and redirect" do
    do_post
    session[:user].should.not.be.nil
    should.redirect
  end

  specify "should set last_logged_in_at to Time.now" do
    do_post
    User.find(session[:user]).last_logged_in_at.to_s.should.equal Time.now.to_s
  end

  specify "should fail login and not redirect" do
    do_post(:password => 'bad password')
    session[:user].should.be.nil
    status.should.be :success
    template.should.be "dt/sessions/new"
  end

  specify "when not activated, should fail login" do
    do_post( :login => 'aaron@example.com' )
    session[:user].should.be.nil
  end

  specify "when not activated, should show a 'not activated' message" do
    do_post( :login => 'aaron@example.com' )
    assigns(:activated).should.be false
    page.should.select "div.activation", :text => /An email has been sent to your login email address to make sure it is a valid address./
  end

  specify "when not activated with correct login and wrong password, @activated should be nil" do
    do_post( :login => 'aaron@example.com', :password => "wrongpassword" )
    assigns(:activated).should.be nil
  end
  
  specify "when not activated with correct login and wrong password, should show a 'username or password are incorrect' message" do
    do_post( :login => 'aaron@example.com', :password => "wrongpassword" )
    page.should.not.select "div.activation"
  end

  specify "when activated with correct login and wrong address, should show a 'username or password are incorrect' message" do
    do_post( :password => "wrongpassword" )
    assigns(:activated).should.be nil
    page.should.not.select "div.activation"
  end

  specify "should remember me" do
    do_post( :remember_me => "1" )
    @response.cookies["auth_token"].should.not.be.nil
  end

  specify "should not remember_me" do
    do_post( :remember_me => "0" )
    @response.cookies["auth_token"].should.be.nil
  end

  specify "should login with cookie" do
    users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    @controller.send(:logged_in?).should.be true
  end

  specify "should fail expired cookie login" do
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    @controller.send(:logged_in?).should.be false
  end

  specify "should fail cookie login" do
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    @controller.send(:logged_in?).should.be false
  end

  specify "should set a cookie with current_user.id" do
    do_post
    get :new
    cookies['login_id'].should.equal ["1"]
    cookies['login_name'].should.equal ["Quentin T."]
  end

  protected
    def do_post(options = {})
      post :create, {:login => 'quentin@example.com', :password => 'test'}.merge(options)
    end
  
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end

    def cookie_for(user)
      auth_token users(user).remember_token
    end
end

context "Dt::Sessions handling logout requests" do
  use_controller Dt::SessionsController
  include DtAuthenticatedTestHelper
  fixtures :users

  specify "should logout" do
    login_as :quentin
    get :destroy
    session[:user].should.be.nil
    should.redirect
  end

  specify "should delete token on logout" do
    login_as :quentin
    get :destroy
    @response.cookies["auth_token"].should.equal []
  end

  specify "should delete login cookie on logout" do
    login_as :quentin
    get :destroy
    @response.cookies["login_id"].should.equal []
    @response.cookies["login_name"].should.equal []
  end

end
