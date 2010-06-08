require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/collaborating_agencies_controller'

# Re-raise errors caught by the controller.
class BusAdmin::CollaboratingAgenciesController; def rescue_action(e) raise e end; end

class BusAdmin::CollaboratingAgenciesControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_collaborating_agencies

  def setup
    @controller = BusAdmin::CollaboratingAgenciesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_collaborating_agencies)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_collaborating_agency
    old_count = collaborating_agency.count
    post :create, :collaborating_agency => { }
    assert_equal old_count+1, collaborating_agency.count
    
    assert_redirected_to collaborating_agency_path(assigns(:collaborating_agency))
  end

  def test_should_show_collaborating_agency
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_collaborating_agency
    put :update, :id => 1, :collaborating_agency => { }
    assert_redirected_to collaborating_agency_path(assigns(:collaborating_agency))
  end
  
  def test_should_destroy_collaborating_agency
    old_count = collaborating_agency.count
    delete :destroy, :id => 1
    assert_equal old_count-1, collaborating_agency.count
    
    assert_redirected_to bus_admin_collaborating_agencies_path
  end
end
