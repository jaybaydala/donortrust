require File.dirname(__FILE__) + '/../test_helper'
require 'project_categories_controller'

# Re-raise errors caught by the controller.
class ProjectCategoriesController; def rescue_action(e) raise e end; end

class ProjectCategoriesControllerTest < Test::Unit::TestCase
  fixtures :project_categories

  def setup
    @controller = ProjectCategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:project_categories)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_project_category
    old_count = ProjectCategory.count
    post :create, :project_category => { :description => "Category 3 description" }
    assert_equal old_count+1, ProjectCategory.count
    
    assert_redirected_to project_category_path(assigns(:project_category))
  end

  def test_should_show_project_category
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_project_category
    put :update, :id => 1, :project_category => { :description => "Category 3 description" }
    assert_redirected_to project_category_path(assigns(:project_category))
  end
  
  def test_should_destroy_project_category
    old_count = ProjectCategory.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ProjectCategory.count
    
    assert_redirected_to project_categories_path
  end
end
