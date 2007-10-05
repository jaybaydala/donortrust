require File.dirname(__FILE__) + '/../test_helper'

class BudgetItemTest < Test::Unit::TestCase
  fixtures :projects
  fixtures :budget_items

  should_belong_to :project

end
