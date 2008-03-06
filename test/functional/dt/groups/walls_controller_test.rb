require File.dirname(__FILE__) + '/../../../test_helper'
require 'dt/groups/walls_controller'

# Re-raise errors caught by the controller.
class Dt::Groups::WallsController; def rescue_action(e) raise e end; end

class Dt::Groups::WallsControllerTest < Test::Unit::TestCase

  def setup
    @controller = Dt::Groups::WallsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
