require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/rank_types_controller'

# Re-raise errors caught by the controller.
class BusAdmin::RankTypesController; def rescue_action(e) raise e end; end

class BusAdmin::RankTypesControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_rank_types

  def setup
    @controller = BusAdmin::RankTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_rank_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_rank_type
    old_count = rank_type.count
    post :create, :rank_type => { }
    assert_equal old_count+1, rank_type.count
    
    assert_redirected_to rank_type_path(assigns(:rank_type))
  end

  def test_should_show_rank_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_rank_type
    put :update, :id => 1, :rank_type => { }
    assert_redirected_to rank_type_path(assigns(:rank_type))
  end
  
  def test_should_destroy_rank_type
    old_count = rank_type.count
    delete :destroy, :id => 1
    assert_equal old_count-1, rank_type.count
    
    assert_redirected_to bus_admin_rank_types_path
  end
end
