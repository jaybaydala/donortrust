require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/wishlists_controller'

# Re-raise errors caught by the controller.
class Dt::WishlistsController; def rescue_action(e) raise e end; end

class Dt::WishlistsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Dt::WishlistsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
