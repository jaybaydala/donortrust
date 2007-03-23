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
    
    @project_one = projects(:project_one)
  end
  
  def test_should_get_index
    get :index, { :project_id => @project_one.id }
    assert_response :success
    assert assigns(:project_histories)
  end  

  def test_should_get_new
    get :new, { :project_id => @project_one.id }
    assert_response :success
  end
  
  def test_should_create_project_history
    old_count = ProjectHistory.count
    post :create, { :project_id => @project_one.id, :project_history => { } }
    assert_equal old_count+1, ProjectHistory.count
    
    assert_redirected_to project_history_path(assigns(:project), assigns(:project_history))
  end

  def test_should_show_project_history
    get :show, { :project_id => @project_one.id, :id => 1 }
    assert_response :success
  end

  def test_should_get_edit
    get :edit, { :project_id => @project_one.id, :id => 1 }
    assert_response :success
  end
  
  def test_should_update_project_history
    put :update, { :project_id => @project_one.id, :id => 1, :project_history => { } }
    assert_redirected_to project_history_path(assigns(:project), assigns(:project_history))
  end
  
  def test_destroy_should_not_work
    old_count = Project.count
    assert_raise ActionController::RoutingError do
      delete :destroy, :id => 1
    end  
    assert_equal old_count, Project.count
  end
  
end
