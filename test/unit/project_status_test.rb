require File.dirname(__FILE__) + '/../test_helper'

class ProjectStatusTest < Test::Unit::TestCase
  fixtures :project_statuses

  def test_invalid_with_empty_status_type
    project_status = ProjectStatus.new
    assert !project_status.valid?
    assert project_status.errors.invalid?(:status_type)
  end
  
  def test_unique_status_type
    project_status = ProjectStatus.new( :status_type => project_statuses(:test_project_status_one).status_type )
    assert !project_status.valid?
  end
  
end
