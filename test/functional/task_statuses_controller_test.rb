require File.dirname(__FILE__) + '/../test_helper'
require 'task_statuses_controller'

# Re-raise errors caught by the controller.
class TaskStatusesController; def rescue_action(e) raise e end; end

class TaskStatusesControllerTest < Test::Unit::TestCase
  fixtures :task_statuses

  def setup
    @controller = TaskStatusesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:task_statuses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_task_status
    old_count = TaskStatus.count
    post :create, :task_status => {
      :status => "junkstatus", :description => "junkdescription" }
    assert_equal old_count+1, TaskStatus.count
    
    assert_redirected_to task_status_path(assigns(:task_status))
  end

  def test_should_show_task_status
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_task_status
    put :update, :id => 1, :task_status => { }
    assert_redirected_to task_status_path(assigns(:task_status))
  end
  
  def test_should_destroy_task_status
    old_count = TaskStatus.count
    delete :destroy, :id => 1
    assert_equal old_count-1, TaskStatus.count
    
    assert_redirected_to task_statuses_path
  end
end
