require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/task_categories_controller'

# Re-raise errors caught by the controller.
class BusAdmin::TaskCategoriesController; def rescue_action(e) raise e end; end

 
class BusAdmin::TaskCategoriesControllerTest < Test::Unit::TestCase
  fixtures :task_categories

  def setup
    @controller = BusAdmin::TaskCategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @useless = nil
  end

  def test_should_get_index
    get :index
    assert_response :success
    #assert assigns(:bus_admin_task_categories)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_task_category
    old_count = TaskCategory.count
    post :create, :task_category => { }
    assert_equal old_count+1, TaskCategory.count
    
    assert_redirected_to task_category_path(assigns(:task_category))
  end

  def test_should_show_task_category
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_task_category
    put :update, :id => 1, :task_category => { }
    assert_redirected_to task_category_path(assigns(:task_category))
  end
  
  def test_should_destroy_task_category
    old_count = TaskCategory.count
    delete :destroy, :id => 1
    assert_equal old_count-1, TaskCategory.count
    
    assert_redirected_to bus_admin_task_categories_path
  end
end
