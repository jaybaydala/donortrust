require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/projects_controller'

# Re-raise errors caught by the controller.
class BusAdmin::ProjectsController; def rescue_action(e) raise e end; end

class BusAdmin::ProjectsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_projects

  def setup
    @controller = BusAdmin::ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_projects)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_project
    old_count = BusAdmin::Project.count
    post :create, :project => { }
    assert_equal old_count+1, BusAdmin::Project.count
    
    assert_redirected_to project_path(assigns(:project))
  end

  def test_should_show_project
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_project
    put :update, :id => 1, :project => { }
    assert_redirected_to project_path(assigns(:project))
  end
  
  def test_should_destroy_project
    old_count = BusAdmin::Project.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::Project.count
    
    assert_redirected_to bus_admin_projects_path
  end
end
