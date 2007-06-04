require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/milestone_categories_controller'

# Re-raise errors caught by the controller.
class BusAdmin::MilestoneCategoriesController; def rescue_action(e) raise e end; end

class BusAdmin::MilestoneCategoriesControllerTest < Test::Unit::TestCase
  fixtures :milestone_categories

  def setup
    @controller = BusAdmin::MilestoneCategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    #assert assigns(:bus_admin_milestone_categories)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_milestone_category
    old_count =MilestoneCategory.count
    post :create, :milestone_category => { }
    assert_equal old_count+1, MilestoneCategory.count
    
    assert_redirected_to milestone_category_path(assigns(:milestone_category))
  end

  def test_should_show_milestone_category
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_milestone_category
    put :update, :id => 1, :milestone_category => { }
    assert_redirected_to milestone_category_path(assigns(:milestone_category))
  end
  
  def test_should_destroy_milestone_category
    old_count = MilestoneCategory.count
    delete :destroy, :id => 1
    assert_equal old_count-1, MilestoneCategory.count
    
    assert_redirected_to bus_admin_milestone_categories_path
  end
end
