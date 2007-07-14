require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/measurements_controller'

# Re-raise errors caught by the controller.
class BusAdmin::MeasurementsController; def rescue_action(e) raise e end; end

class BusAdmin::MeasurementsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_measurements

  def setup
    @controller = BusAdmin::MeasurementsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_measurements)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_measurement
    old_count = measurement.count
    post :create, :measurement => { }
    assert_equal old_count+1, measurement.count
    
    assert_redirected_to measurement_path(assigns(:measurement))
  end

  def test_should_show_measurement
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_measurement
    put :update, :id => 1, :measurement => { }
    assert_redirected_to measurement_path(assigns(:measurement))
  end
  
  def test_should_destroy_measurement
    old_count = measurement.count
    delete :destroy, :id => 1
    assert_equal old_count-1, measurement.count
    
    assert_redirected_to bus_admin_measurements_path
  end
end
