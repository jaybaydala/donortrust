require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/e_cards_controller'

# Re-raise errors caught by the controller.
class BusAdmin::ECardsController; def rescue_action(e) raise e end; end

class BusAdmin::ECardsControllerTest < ActiveSupport::TestCase
  fixtures :e_cards
  include AuthenticatedTestHelper

  def setup
    @controller = BusAdmin::ECardsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    login_as :quentin
    get :index
    assert_response :success
    assert assigns(:e_cards)
  end

  def test_should_get_new
    login_as :quentin
    get :new
    assert_response :success
  end
  
  def test_should_create_e_card
    login_as :quentin
    old_count = ECard.count
    post :create, :e_card => { }
    assert_equal old_count+1, ECard.count
    
    assert_redirected_to e_card_path(assigns(:e_card))
  end

  def test_should_show_e_card
    login_as :quentin
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :quentin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_e_card
    login_as :quentin
    put :update, :id => 1, :e_card => { }
    assert_redirected_to e_card_path(assigns(:e_card))
  end
  
  def test_should_destroy_e_card
    login_as :quentin
    old_count = ECard.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ECard.count
    
    assert_redirected_to e_cards_path
  end
end
