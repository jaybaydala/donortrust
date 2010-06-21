require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/rank_values_controller'

# Re-raise errors caught by the controller.
class BusAdmin::RankValuesController; def rescue_action(e) raise e end; end

class BusAdmin::RankValuesControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_rank_values

  def setup
    @controller = BusAdmin::RankValuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_rank_values)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_rank_value
    old_count = rank_value.count
    post :create, :rank_value => { }
    assert_equal old_count+1, rank_value.count
    
    assert_redirected_to rank_value_path(assigns(:rank_value))
  end

  def test_should_show_rank_value
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_rank_value
    put :update, :id => 1, :rank_value => { }
    assert_redirected_to rank_value_path(assigns(:rank_value))
  end
  
  def test_should_destroy_rank_value
    old_count = rank_value.count
    delete :destroy, :id => 1
    assert_equal old_count-1, rank_value.count
    
    assert_redirected_to bus_admin_rank_values_path
  end
end
