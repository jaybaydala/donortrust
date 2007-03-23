require File.dirname(__FILE__) + '/../test_helper'
require 'continents_controller'

# Re-raise errors caught by the controller.
class ContinentsController; def rescue_action(e) raise e end; end

class ContinentsControllerTest < Test::Unit::TestCase
  fixtures :continents

  def setup
    @controller = ContinentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:continents)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_continent
    old_count = Continent.count
    post :create, :continent => { }
    assert_equal old_count+1, Continent.count
    
    assert_redirected_to continent_path(assigns(:continent))
  end

  def test_should_show_continent
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_continent
    put :update, :id => 1, :continent => { }
    assert_redirected_to continent_path(assigns(:continent))
  end
  
  def test_should_destroy_continent
    old_count = Continent.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Continent.count
    
    assert_redirected_to continents_path
  end
end
