require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/contacts_controller'

# Re-raise errors caught by the controller.
class BusAdmin::ContactsController; def rescue_action(e) raise e end; end

class BusAdmin::ContactsControllerTest < Test::Unit::TestCase
  fixtures :contacts

  def setup
    @controller = ContactsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:contacts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_contacts
    old_count = BusAdmin::Contacts.count
    post :create, :contacts => { }
    assert_equal old_count+1, BusAdmin::Contacts.count
    
    assert_redirected_to contacts_path(assigns(:contacts))
  end

  def test_should_show_contacts
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_contacts
    put :update, :id => 1, :contacts => { }
    assert_redirected_to contacts_path(assigns(:contacts))
  end
  
  def test_should_destroy_contacts
    old_count = BusAdmin::Contacts.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::Contacts.count
    
    assert_redirected_to bus_admin_contacts_path
  end
end
