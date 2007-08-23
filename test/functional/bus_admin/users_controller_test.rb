require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/users_controller'

# Re-raise errors caught by the controller.
class BusAdmin::UsersController; def rescue_action(e) raise e end; end

class BusAdmin::UsersControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_users

  def setup
    @controller = BusAdmin::UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_users)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_user
    old_count = user.count
    post :create, :user => { }
    assert_equal old_count+1, user.count
    
    assert_redirected_to user_path(assigns(:user))
  end

  def test_should_show_user
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_user
    put :update, :id => 1, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end
  
  def test_should_destroy_user
    old_count = user.count
    delete :destroy, :id => 1
    assert_equal old_count-1, user.count
    
    assert_redirected_to bus_admin_users_path
  end
end
