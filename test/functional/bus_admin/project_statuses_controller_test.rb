require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/project_statuses_controller'

# Re-raise errors caught by the controller.
class BusAdmin::ProjectStatusesController; def rescue_action(e) raise e end; end

class BusAdmin::ProjectStatusesControllerTest < ActiveSupport::TestCase
  fixtures :project_statuses

  def setup
    @controller = BusAdmin::ProjectStatusesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:project_statuses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_project_status
    old_count = ProjectStatus.count
    post :create, :project_status => { :name => "On Hold" }
    assert_equal old_count+1, ProjectStatus.count
    
    assert_redirected_to project_status_path(assigns(:project_status))
  end

  def test_should_show_project_status
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_project_status
    put :update, :id => 1, :project_status => { :name => "On Hold" }
    assert_redirected_to project_status_path(assigns(:project_status))
  end
  
  def test_should_destroy_project_status
    old_count = ProjectStatus.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ProjectStatus.count
    
    assert_redirected_to project_statuses_path
  end
end
