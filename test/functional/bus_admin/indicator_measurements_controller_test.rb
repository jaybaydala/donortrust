require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/indicator_measurements_controller'

# Re-raise errors caught by the controller.
class BusAdmin::IndicatorMeasurementsController; def rescue_action(e) raise e end; end

class BusAdmin::IndicatorMeasurementsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_indicator_measurements

  def setup
    @controller = BusAdmin::IndicatorMeasurementsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_indicator_measurements)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_indicator_measurement
    old_count = indicator_measurement.count
    post :create, :indicator_measurement => { }
    assert_equal old_count+1, indicator_measurement.count
    
    assert_redirected_to indicator_measurement_path(assigns(:indicator_measurement))
  end

  def test_should_show_indicator_measurement
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_indicator_measurement
    put :update, :id => 1, :indicator_measurement => { }
    assert_redirected_to indicator_measurement_path(assigns(:indicator_measurement))
  end
  
  def test_should_destroy_indicator_measurement
    old_count = indicator_measurement.count
    delete :destroy, :id => 1
    assert_equal old_count-1, indicator_measurement.count
    
    assert_redirected_to bus_admin_indicator_measurements_path
  end
end
