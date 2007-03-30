require File.dirname(__FILE__) + '/../test_helper'
require 'programs_controller'

# Re-raise errors caught by the controller.
class ProgramsController; def rescue_action(e) raise e end; end

class ProgramsControllerTest < Test::Unit::TestCase
  fixtures :programs

  def setup
    @controller = ProgramsController.new
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
  
  def test_should_create_programs
    old_count = Programs.count
    post :create, :programs => { }
    assert_equal old_count+1, Programs.count
    
    assert_redirected_to programs_path(assigns(:programs))
  end

  def test_should_show_programs
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_programs
    put :update, :id => 1, :programs => { }
    assert_redirected_to programs_path(assigns(:programs))
  end
  
  def test_should_destroy_programs
    old_count = Programs.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Programs.count
    
    assert_redirected_to programs_path
  end
end
