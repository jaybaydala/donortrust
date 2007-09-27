require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/ranks_controller'

# Re-raise errors caught by the controller.
class BusAdmin::RanksController; def rescue_action(e) raise e end; end

class BusAdmin::RanksControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_ranks

  def setup
    @controller = BusAdmin::RanksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_ranks)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_rank
    old_count = rank.count
    post :create, :rank => { }
    assert_equal old_count+1, rank.count
    
    assert_redirected_to rank_path(assigns(:rank))
  end

  def test_should_show_rank
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_rank
    put :update, :id => 1, :rank => { }
    assert_redirected_to rank_path(assigns(:rank))
  end
  
  def test_should_destroy_rank
    old_count = rank.count
    delete :destroy, :id => 1
    assert_equal old_count-1, rank.count
    
    assert_redirected_to bus_admin_ranks_path
  end
end
