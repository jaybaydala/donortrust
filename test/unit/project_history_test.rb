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
  
  def test_new_audit_should_copy_data_from_project
  
    project = projects(:project_one)
    project_history = ProjectHistory.new_audit(project)
  
    assert_equal project.id, project_history.project_id
    assert_equal project.expected_completion_date, project_history.expected_completion_date
    assert_equal project.project_status_id, project_history.project_status_id
    assert_equal project.project_category_id, project_history.project_category_id  
  
    ProjectHistory.logger.debug("project_history.id=#{project_history.id}")
  
  end
  
end
