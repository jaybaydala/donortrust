require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/programs_controller'

# Re-raise errors caught by the controller.
class BusAdmin::ProgramsController; def rescue_action(e) raise e end; end

class BusAdmin::ProgramsControllerTest < ActiveSupport::TestCase
  fixtures :programs

  def setup
    @controller = BusAdmin::ProgramsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:programs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_program
    old_count = Program.count
    post :create, :program => { }
    assert_equal old_count+1, Program.count
    
    assert_redirected_to program_path(assigns(:program))
  end

  def test_should_show_program
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_program
    put :update, :id => 1, :program => { }
    assert_redirected_to program_path(assigns(:program))
  end
  
  def test_should_destroy_program
    old_count = Program.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Program.count
    
    assert_redirected_to programs_path
  end
end
