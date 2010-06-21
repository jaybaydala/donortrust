require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/quick_fact_partners_controller'

# Re-raise errors caught by the controller.
class BusAdmin::QuickFactPartnersController; def rescue_action(e) raise e end; end

class BusAdmin::QuickFactPartnersControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_quick_fact_partners

  def setup
    @controller = BusAdmin::QuickFactPartnersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_quick_fact_partners)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_quick_fact_partner
    old_count = quick_fact_partner.count
    post :create, :quick_fact_partner => { }
    assert_equal old_count+1, quick_fact_partner.count
    
    assert_redirected_to quick_fact_partner_path(assigns(:quick_fact_partner))
  end

  def test_should_show_quick_fact_partner
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_quick_fact_partner
    put :update, :id => 1, :quick_fact_partner => { }
    assert_redirected_to quick_fact_partner_path(assigns(:quick_fact_partner))
  end
  
  def test_should_destroy_quick_fact_partner
    old_count = quick_fact_partner.count
    delete :destroy, :id => 1
    assert_equal old_count-1, quick_fact_partner.count
    
    assert_redirected_to bus_admin_quick_fact_partners_path
  end
end
