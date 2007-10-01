require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/e_cards_controller'

# Re-raise errors caught by the controller.
class BusAdmin::ECardsController; def rescue_action(e) raise e end; end

class BusAdmin::ECardsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_e_cards

  def setup
    @controller = BusAdmin::ECardsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_e_cards)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_e_card
    old_count = e_card.count
    post :create, :e_card => { }
    assert_equal old_count+1, e_card.count
    
    assert_redirected_to e_card_path(assigns(:e_card))
  end

  def test_should_show_e_card
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_e_card
    put :update, :id => 1, :e_card => { }
    assert_redirected_to e_card_path(assigns(:e_card))
  end
  
  def test_should_destroy_e_card
    old_count = e_card.count
    delete :destroy, :id => 1
    assert_equal old_count-1, e_card.count
    
    assert_redirected_to bus_admin_e_cards_path
  end
end
