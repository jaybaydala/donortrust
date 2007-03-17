require File.dirname(__FILE__) + '/../test_helper'

class ProjectHistoryTest < Test::Unit::TestCase
  fixtures :projects
  fixtures :project_histories

  def test_invalid_with_empty_project_id
    projectHistory = ProjectHistory.new
    assert !projectHistory.valid?
    assert projectHistory.errors.invalid?(:project_id)
  end
  
  def test_should_not_add_project_histroy_without_project
  
    projectHistory = ProjectHistory.new
    # TODO: Query projects, find the biggest project_id, and use the value one bigger than that here:
    projectHistory.project_id = 100
    assert !projectHistory.save
  
  end
  
end
