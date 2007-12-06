require File.dirname(__FILE__) + '/../test_helper'
require 'bus_accounts_controller'

# Re-raise errors caught by the controller.
class BusAccountsController; def rescue_action(e) raise e end; end

class BusAccountsControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :bus_accounts

  def setup
    @controller = BusAccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_login_and_redirect
    post :login, :login => 'quentin', :password => 'test'
    assert session[:bus_account]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'quentin', :password => 'bad password'
    assert_nil session[:bus_account]
    assert_response :success
  end

  def test_should_allow_signup
    assert_difference BusAccount, :count do
      create_bus_account
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference BusAccount, :count do
      create_bus_account(:login => nil)
      assert assigns(:bus_account).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference BusAccount, :count do
      create_bus_account(:password => nil)
      assert assigns(:bus_account).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference BusAccount, :count do
      create_bus_account(:password_confirmation => nil)
      assert assigns(:bus_account).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference BusAccount, :count do
      create_bus_account(:email => nil)
      assert assigns(:bus_account).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_logout
    login_as :quentin
    get :logout
    assert_nil session[:bus_account]
    assert_response :redirect
  end

  def test_should_remember_me
    post :login, :login => 'quentin', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :login, :login => 'quentin', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :logout
    assert_equal @response.cookies["auth_token"], []
  end

  def test_should_login_with_cookie
    bus_accounts(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    bus_accounts(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    bus_accounts(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :index
    assert !@controller.send(:logged_in?)
  end

  protected
    def create_bus_account(options = {})
      post :signup, :bus_account => { :login => 'quire', :email => 'quire@example.com', 
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
    
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(bus_account)
      auth_token bus_accounts(bus_account).remember_token
    end
end
