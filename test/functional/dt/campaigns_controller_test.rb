require File.dirname(__FILE__) + '/../../test_helper'

class Dt::CampaignsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:dt_campaigns)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_campaign
    assert_difference('Dt::Campaign.count') do
      post :create, :campaign => { }
    end

    assert_redirected_to campaign_path(assigns(:campaign))
  end

  def test_should_show_campaign
    get :show, :id => dt_campaigns(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => dt_campaigns(:one).id
    assert_response :success
  end

  def test_should_update_campaign
    put :update, :id => dt_campaigns(:one).id, :campaign => { }
    assert_redirected_to campaign_path(assigns(:campaign))
  end

  def test_should_destroy_campaign
    assert_difference('Dt::Campaign.count', -1) do
      delete :destroy, :id => dt_campaigns(:one).id
    end

    assert_redirected_to dt_campaigns_path
  end
end
