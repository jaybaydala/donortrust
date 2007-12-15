require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/key_measure_datas_controller'

# Re-raise errors caught by the controller.
class BusAdmin::KeyMeasureDatasController; def rescue_action(e) raise e end; end

class BusAdmin::KeyMeasureDatasControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_key_measure_datas

  def setup
    @controller = BusAdmin::KeyMeasureDatasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_key_measure_datas)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_key_measure_data
    old_count = key_measure_data.count
    post :create, :key_measure_data => { }
    assert_equal old_count+1, key_measure_data.count
    
    assert_redirected_to key_measure_data_path(assigns(:key_measure_data))
  end

  def test_should_show_key_measure_data
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_key_measure_data
    put :update, :id => 1, :key_measure_data => { }
    assert_redirected_to key_measure_data_path(assigns(:key_measure_data))
  end
  
  def test_should_destroy_key_measure_data
    old_count = key_measure_data.count
    delete :destroy, :id => 1
    assert_equal old_count-1, key_measure_data.count
    
    assert_redirected_to bus_admin_key_measure_datas_path
  end
end
