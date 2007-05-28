require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/countries_controller'

# Re-raise errors caught by the controller.
class BusAdmin::CountriesController; def rescue_action(e) raise e end; end

class BusAdmin::CountriesControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_countries

  def setup
    @controller = BusAdmin::CountriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_countries)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_country
    old_count = BusAdmin::Country.count
    post :create, :country => { }
    assert_equal old_count+1, BusAdmin::Country.count
    
    assert_redirected_to country_path(assigns(:country))
  end

  def test_should_show_country
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_country
    put :update, :id => 1, :country => { }
    assert_redirected_to country_path(assigns(:country))
  end
  
  def test_should_destroy_country
    old_count = BusAdmin::Country.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::Country.count
    
    assert_redirected_to bus_admin_countries_path
  end
end
