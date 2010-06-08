require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/partner_statuses_controller'

# Re-raise errors caught by the controller.
class BusAdmin::PartnerStatusesController; def rescue_action(e) raise e end; end

class BusAdmin::PartnerStatusesControllerTest < ActiveSupport::TestCase
  fixtures :partner_statuses

  def setup
    @controller = BusAdmin::PartnerStatusesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    #assert assigns(:bus_admin_partner_statuses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_partner_status
    old_count = PartnerStatus.count
    post :create, :partner_status => { }
    assert_equal old_count+1, PartnerStatus.count
    
    assert_redirected_to partner_status_path(assigns(:partner_status))
  end

  def test_should_show_partner_status
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_partner_status
    put :update, :id => 1, :partner_status => { }
    assert_redirected_to partner_status_path(assigns(:partner_status))
  end
  
  def test_should_destroy_partner_status
    old_count = PartnerStatus.count
    delete :destroy, :id => 1
    assert_equal old_count-1, PartnerStatus.count
    
    assert_redirected_to bus_admin_partner_statuses_path
  end
end
