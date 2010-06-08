require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/frequency_types_controller'

# Re-raise errors caught by the controller.
class BusAdmin::FrequencyTypesController; def rescue_action(e) raise e end; end

class BusAdmin::FrequencyTypesControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_frequency_types

  def setup
    @controller = BusAdmin::FrequencyTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_frequency_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_frequency_type
    old_count = frequency_type.count
    post :create, :frequency_type => { }
    assert_equal old_count+1, frequency_type.count
    
    assert_redirected_to frequency_type_path(assigns(:frequency_type))
  end

  def test_should_show_frequency_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_frequency_type
    put :update, :id => 1, :frequency_type => { }
    assert_redirected_to frequency_type_path(assigns(:frequency_type))
  end
  
  def test_should_destroy_frequency_type
    old_count = frequency_type.count
    delete :destroy, :id => 1
    assert_equal old_count-1, frequency_type.count
    
    assert_redirected_to bus_admin_frequency_types_path
  end
end
