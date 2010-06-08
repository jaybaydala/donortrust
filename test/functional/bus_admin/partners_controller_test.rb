require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/partners_controller'

# Re-raise errors caught by the controller.
class BusAdmin::PartnersController; def rescue_action(e) raise e end; end

class BusAdmin::PartnersControllerTest < ActiveSupport::TestCase
  fixtures :partners

  def setup
    @controller = BusAdmin::PartnersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:partners)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_partners
    old_count = Partners.count
    post :create, :partners => { }
    assert_equal old_count+1, Partners.count
    
    assert_redirected_to partners_path(assigns(:partners))
  end

  def test_should_show_partners
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_partners
    put :update, :id => 1, :partners => { }
    assert_redirected_to partners_path(assigns(:partners))
  end
  
  def test_should_destroy_partners
    old_count = Partners.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Partners.count
    
    assert_redirected_to partners_path
  end
end
