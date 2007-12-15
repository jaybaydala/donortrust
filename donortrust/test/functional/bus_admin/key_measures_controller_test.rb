require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/key_measures_controller'

# Re-raise errors caught by the controller.
class BusAdmin::KeyMeasuresController; def rescue_action(e) raise e end; end

class BusAdmin::KeyMeasuresControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_key_measures

  def setup
    @controller = BusAdmin::KeyMeasuresController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_key_measures)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_key_measure
    old_count = key_measure.count
    post :create, :key_measure => { }
    assert_equal old_count+1, key_measure.count
    
    assert_redirected_to key_measure_path(assigns(:key_measure))
  end

  def test_should_show_key_measure
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_key_measure
    put :update, :id => 1, :key_measure => { }
    assert_redirected_to key_measure_path(assigns(:key_measure))
  end
  
  def test_should_destroy_key_measure
    old_count = key_measure.count
    delete :destroy, :id => 1
    assert_equal old_count-1, key_measure.count
    
    assert_redirected_to bus_admin_key_measures_path
  end
end
