require File.dirname(__FILE__) + '/../test_helper'
require 'tasks_controller'

# Re-raise errors caught by the controller.
class TasksController; def rescue_action(e) raise e end; end

class TasksControllerTest < Test::Unit::TestCase
  fixtures :milestones, :task_statuses, :task_categories, :tasks

  def setup
    @controller = TasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index, :milestone_id => milestones( :one )
    assert_response :success
    assert assigns(:tasks)
  end

  def test_should_get_new
    get :new, :milestone_id => milestones( :one )
    assert_response :success
  end
  
  def test_should_create_task
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

  def test_should_show_task
    get :show, :id => tasks( :taskone ), :milestone_id => milestones( :one )
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => tasks( :taskone ), :milestone_id => milestones( :one )
    assert_response :success
  end
  
  def test_should_update_task
    #fail if checking for no change
    put :update, :id => tasks( :taskone ), :task => { }, :milestone_id => milestones( :one )
    assert_redirected_to task_path( milestones( :one ), assigns( :task ))
  end
  
  def test_should_destroy_task
    old_count = Task.count
    delete :destroy, :id => tasks( :taskone ), :milestone_id => milestones( :one )
    assert_equal old_count-1, Task.count
    
    assert_redirected_to tasks_path( milestones( :one ))
  end
end
