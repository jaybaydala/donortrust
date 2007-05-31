require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/tasks_controller'

# Re-raise errors caught by the controller.
class BusAdmin::TasksController; def rescue_action(e) raise e end; end

class BusAdmin::TasksControllerTest < Test::Unit::TestCase
  fixtures :programs, :projects, :milestones, :task_statuses, :task_categories, :tasks

  def setup
    @controller = BusAdmin::TasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

#  def test_should_get_index
#    get :index
#    assert_response :success
#    #assert assigns(:bus_admin_tasks)
#  end
#  def test_should_get_index2
#    get :index, :milestone_id => milestones( :one )
#    assert_response :success
#    #assert assigns(:tasks)
#    #assert assigns(:tasksxxx), "assigns keys: #{assigns.keys.inspect}"
#    # Test::Unit::AssertionFailedError: assigns keys: ["template_root", "template_class", "response", "_session", 
#    # "action_name", "session", "template", "url", "request_origin", "_response", "_cookies", "_request", 
#    # "params", "_flash", "variables_added", "tasks", "_headers", "ignore_missing_templates", "request", 
#    # "cookies", "logger", "milestone", "flash", "_params", "headers", "before_filter_chain_aborted"].
#    #assert assigns(:tasksxxx), "assigns[:tasks]: #{assigns[:tasks].inspect}"
#    # Test::Unit::AssertionFailedError: assigns[:tasks]: nil.
#  end

#  def test_should_get_new
#    get :new
#    assert_response :success
#  end
#  def test_should_get_new2
#    get :new, :milestone_id => milestones( :one )
#    assert_response :success
#  end
  
#  def test_should_create_task
#    old_count = Task.count
#    post :create, :task => { }
#    assert_equal old_count+1, Task.count
#    
#    assert_redirected_to task_path(assigns(:task))
#  end
  def test_should_create_task2
    old_count = Task.count
    # does this need (2nd) milestone_id if model copies automatically? (when nested resource)
    post :create,
      :milestone_id => milestones( :one ),
      :task => {
        :milestone_id => milestones( :one ),
        :title => "new title",
        :task_category_id => task_categories( :testone ),
        :task_status_id => task_statuses( :proposed ),
        :description => "enough description to be valid" }
        # date fields are optional
    assert_equal old_count+1, Task.count
    
    assert_redirected_to task_path( milestones( :one ), assigns( :task ))
  end

#  def test_should_show_task
#    get :show, :id => 1
#    assert_response :success
#  end
#  def test_should_show_task2
#    get :show, :id => tasks( :taskone ), :milestone_id => milestones( :one )
#    assert_response :success
#  end
#
#  def test_should_get_edit
#    get :edit, :id => 1
#    assert_response :success
#  end
#  def test_should_get_edit2
#    get :edit, :id => tasks( :taskone ), :milestone_id => milestones( :one )
#    assert_response :success
#  end
#  
#  def test_should_update_task
#    put :update, :id => 1, :task => { }
#    assert_redirected_to task_path(assigns(:task))
#  end
#  def test_should_update_task2
#    #fail if checking for no change
#    put :update, :id => tasks( :taskone ), :task => { }, :milestone_id => milestones( :one )
#    assert_redirected_to task_path( milestones( :one ), assigns( :task ))
#  end
#  
#  def test_should_destroy_task
#    old_count = Task.count
#    delete :destroy, :id => 1
#    assert_equal old_count-1, Task.count
#    
#    assert_redirected_to bus_admin_tasks_path
#  end
#  # hpd what should destroy do when [always should] have history records?
#  def test_should_destroy_task2
#    old_count = Task.count
#    delete :destroy, :id => tasks( :taskone ), :milestone_id => milestones( :one )
#    assert_equal old_count-1, Task.count
#    
#    assert_redirected_to bus_admin_tasks_path( milestones( :one ))
#  end
end
