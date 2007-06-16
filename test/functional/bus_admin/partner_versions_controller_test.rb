require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/partner_versions_controller'

# Re-raise errors caught by the controller.
class BusAdmin::PartnerVersionsController; def rescue_action(e) raise e end; end

class BusAdmin::PartnerVersionsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_partner_versions

  def setup
    @controller = BusAdmin::PartnerVersionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_partner_versions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_partner_version
    old_count = partner_version.count
    post :create, :partner_version => { }
    assert_equal old_count+1, partner_version.count
    
    assert_redirected_to partner_version_path(assigns(:partner_version))
  end

  def test_should_show_partner_version
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_partner_version
    put :update, :id => 1, :partner_version => { }
    assert_redirected_to partner_version_path(assigns(:partner_version))
  end
  
  def test_should_destroy_partner_version
    old_count = partner_version.count
    delete :destroy, :id => 1
    assert_equal old_count-1, partner_version.count
    
    assert_redirected_to bus_admin_partner_versions_path
  end
end
