require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/budget_items_controller'

# Re-raise errors caught by the controller.
class BusAdmin::BudgetItemsController; def rescue_action(e) raise e end; end

class BusAdmin::BudgetItemsControllerTest < Test::Unit::TestCase
  fixtures :budget_items

  def setup
    @controller = BusAdmin::BudgetItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @budget_item = budget_items(:budget_item_one)
  end

  # Generates all the necessary tests in the similar way "active_scaffold :budget_items do |config| ..." 
  # generates the necessary controller's and view's codes: 
  should_be_restful do |resource|
    resource.klass = BudgetItem
    resource.formats = [:html]
  end

end
