require File.dirname(__FILE__) + '/../test_helper'
require 'measure_categories_controller'

# Re-raise errors caught by the controller.
class MeasureCategoriesController; def rescue_action(e) raise e end; end

class MeasureCategoriesControllerTest < Test::Unit::TestCase
  fixtures :measure_categories

  def setup
    @controller = MeasureCategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:measure_categories)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_measure_category
    old_count = MeasureCategory.count
    post :create, :measure_category => {
      :category => "xyzcategoryxyz", :description => "category description" }
    assert_equal old_count+1, MeasureCategory.count
    
    assert_redirected_to measure_category_path(assigns(:measure_category))
  end

  def test_should_show_measure_category
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_measure_category
    put :update, :id => 1, :measure_category => { }
    assert_redirected_to measure_category_path(assigns(:measure_category))
  end
  
  def test_should_destroy_measure_category
    old_count = MeasureCategory.count
    delete :destroy, :id => 1
    assert_equal old_count-1, MeasureCategory.count
    
    assert_redirected_to measure_categories_path
  end
end
