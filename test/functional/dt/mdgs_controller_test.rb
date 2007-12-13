require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/mdgs_controller'

# Re-raise errors caught by the controller.
class Dt::MdgsController; def rescue_action(e) raise e end; end

class Dt::MdgsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Dt::MdgsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
