require File.dirname(__FILE__) + '/../test_helper'
require 'countries_controller'

# Re-raise errors caught by the controller.
class CountriesController; def rescue_action(e) raise e end; end

class CountriesControllerTest < Test::Unit::TestCase
  fixtures :countries

  def setup
    @controller = CountriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:countries)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_country
    old_count = Country.count
    post :create, :country => { }
    assert_equal old_count+1, Country.count
    
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
    old_count = Country.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Country.count
    
    assert_redirected_to countries_path
  end
end
