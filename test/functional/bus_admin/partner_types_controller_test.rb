require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/partner_types_controller'

# Re-raise errors caught by the controller.
class BusAdmin::PartnerTypesController; def rescue_action(e) raise e end; end

class BusAdmin::PartnerTypesControllerTest < ActiveSupport::TestCase
  fixtures :partner_types

  def setup
    @controller = BusAdmin::PartnerTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:partner_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_partner_types
    old_count = PartnerTypes.count
    post :create, :partner_types => { }
    assert_equal old_count+1, PartnerTypes.count
    
    assert_redirected_to partner_types_path(assigns(:partner_types))
  end

  def test_should_show_partner_types
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_partner_types
    put :update, :id => 1, :partner_types => { }
    assert_redirected_to partner_types_path(assigns(:partner_types))
  end
  
  def test_should_destroy_partner_types
    old_count = PartnerTypes.count
    delete :destroy, :id => 1
    assert_equal old_count-1, PartnerTypes.count
    
    assert_redirected_to partner_types_path
  end
end
