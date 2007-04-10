require File.dirname(__FILE__) + '/../test_helper'
require 'task_histories_controller'

# Re-raise errors caught by the controller.
class TaskHistoriesController; def rescue_action(e) raise e end; end

class TaskHistoriesControllerTest < Test::Unit::TestCase
  fixtures :milestones, :task_statuses, :task_categories, :tasks, :task_histories

  def setup
    @controller = TaskHistoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index, :task_id => tasks( :taskone )
    assert_response :success
    assert assigns(:task_histories)
  end

  def test_should_get_new
    get :new, :task_id => tasks( :taskone )
    assert_response :success
  end
  
  def test_should_create_task_history
    old_count = TaskHistory.count
    # does this need (2nd) milestone_id if model copies automatically? (when nested resource)
    post :create,
      :task_id => tasks( :taskone ),
      :task_history => {
        :task_id => tasks( :taskone ),
        :milestone_id => milestones( :one ),
        :task_category_id => task_categories( :testone ),
        :task_status_id => task_statuses( :proposed ) }
    assert_equal old_count+1, TaskHistory.count
    
    assert_redirected_to task_history_path( tasks( :taskone ), assigns( :task_history ))
  end

  def test_should_show_task_history
    get :show, :id => task_histories( :histone ), :task_id => tasks( :taskone )
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => task_histories( :histone ), :task_id => tasks( :taskone )
    assert_response :success
  end
  
  def test_should_update_task_history
    # hpd fails (and it should).  No updates allow to maintain audit trail
    put :update, :id => task_histories( :histone ), :task_history => { }, :task_id => tasks( :taskone )
    assert_redirected_to task_history_path( tasks( :taskone ), assigns( :task_history ))
    # assert status 200 ? success ? no redirect?
  end
  
  def test_should_destroy_task_history
    old_count = TaskHistory.count
    delete :destroy, :id => task_histories( :histone ), :task_id => tasks( :taskone ).id
    assert_equal old_count-1, TaskHistory.count
    
    assert_redirected_to task_histories_path( tasks( :taskone ))
  end
end