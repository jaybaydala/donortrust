require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/financial_sources_controller'

# Re-raise errors caught by the controller.
class BusAdmin::FinancialSourcesController; def rescue_action(e) raise e end; end

class BusAdmin::FinancialSourcesControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_financial_sources

  def setup
    @controller = BusAdmin::FinancialSourcesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_financial_sources)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_financial_source
    old_count = financial_source.count
    post :create, :financial_source => { }
    assert_equal old_count+1, financial_source.count
    
    assert_redirected_to financial_source_path(assigns(:financial_source))
  end

  def test_should_show_financial_source
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_financial_source
    put :update, :id => 1, :financial_source => { }
    assert_redirected_to financial_source_path(assigns(:financial_source))
  end
  
  def test_should_destroy_financial_source
    old_count = financial_source.count
    delete :destroy, :id => 1
    assert_equal old_count-1, financial_source.count
    
    assert_redirected_to bus_admin_financial_sources_path
  end
end
