require File.dirname(__FILE__) + '/../test_helper'
require 'project_histories_controller'

# Re-raise errors caught by the controller.
class ProjectHistoriesController; def rescue_action(e) raise e end; end

class ProjectHistoriesControllerTest < Test::Unit::TestCase
  fixtures :projects
  fixtures :project_histories

  def setup
    @controller = ProjectHistoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_get_index
    get :index, { :project_id => projects(:project_one).id }
    assert_response :success
    assert assigns(:project_histories)
  end  

  def test_should_get_new
    get :new, { :project_id => projects(:project_one).id }
    assert_response :success
  end
  
  def test_should_create_project_history
    old_count = ProjectHistory.count
    post :create, { :project_history => { }, :project_id => projects(:project_one).id }
    assert_equal old_count+1, ProjectHistory.count
    
    assert_redirected_to project_history_path(assigns(:project_history), :project_id => projects(:project_one).id)
  end

  def test_should_show_project_history
    get :show, { :id => 1, :project_id => projects(:project_one).id }
    assert_response :success
  end

  def test_should_get_edit
    get :edit, { :id => 1, :project_id => projects(:project_one).id }
    assert_response :success
  end
  
  def test_should_update_project_history
    put :update, { :id => 1, :project_history => { }, :project_id => projects(:project_one).id }
    assert_redirected_to project_history_path(assigns(:project_history), :project_id => projects(:project_one).id)
  end
  
  def test_destroy_should_not_work
    #TODO
  end
  
end
