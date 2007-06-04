require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/partner_histories_controller'

# Re-raise errors caught by the controller.
class BusAdmin::PartnerHistoriesController; def rescue_action(e) raise e end; end

class BusAdmin::PartnerHistoriesControllerTest < Test::Unit::TestCase
  fixtures :partner_histories

  def setup
    @controller = BusAdmin::PartnerHistoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:partner_histories)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_partner_history
    old_count = PartnerHistory.count
    post :create, :partner_history => { }
    assert_equal old_count+1, PartnerHistory.count
    
    assert_redirected_to partner_history_path(assigns(:partner_history))
  end

  def test_should_show_partner_history
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_partner_history
    put :update, :id => 1, :partner_history => { }
    assert_redirected_to partner_history_path(assigns(:partner_history))
  end
  
  def test_should_destroy_partner_history
    old_count = PartnerHistory.count
    delete :destroy, :id => 1
    assert_equal old_count-1, PartnerHistory.count
    
    assert_redirected_to partner_histories_path
  end
end
