require File.dirname(__FILE__) + '/../test_helper'
require 'measures_controller'

# Re-raise errors caught by the controller.
class MeasuresController; def rescue_action(e) raise e end; end

class MeasuresControllerTest < Test::Unit::TestCase
  fixtures :measure_categories, :measures

  def setup
    @controller = MeasuresController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:measures)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_measure
    old_count = Measure.count
    post :create, :measure => { :measure_category_id => measure_categories( :testone ) }
    assert_equal old_count+1, Measure.count
    
    assert_redirected_to measure_path(assigns(:measure))
  end

  def test_should_show_measure
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_measure
    put :update, :id => 1, :measure => { }
    assert_redirected_to measure_path(assigns(:measure))
  end
  
  def test_should_destroy_measure
    old_count = Measure.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Measure.count
    
    assert_redirected_to measures_path
  end
end
