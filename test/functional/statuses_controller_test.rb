require File.dirname(__FILE__) + '/../test_helper'
require 'statuses_controller'

# Re-raise errors caught by the controller.
class StatusesController; def rescue_action(e) raise e end; end

class StatusesControllerTest < Test::Unit::TestCase
  fixtures :statuses

  def setup
    @controller = StatusesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:statuses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_status
    old_count = Status.count
    post :create, :status => { }
    assert_equal old_count+1, Status.count
    
    assert_redirected_to status_path(assigns(:status))
  end

  def test_should_show_status
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_status
    put :update, :id => 1, :status => { }
    assert_redirected_to status_path(assigns(:status))
  end
  
  def test_should_destroy_status
    old_count = Status.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Status.count
    
    assert_redirected_to statuses_path
  end
end
