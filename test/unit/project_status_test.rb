require File.dirname(__FILE__) + '/../test_helper'

class ProjectStatusTest < Test::Unit::TestCase
  fixtures :project_statuses

  def test_invalid_with_empty_name
    project_status = ProjectStatus.new
    assert !project_status.valid?
    assert project_status.errors.invalid?(:name)
  end
  
  def test_unique_name
    project_status = ProjectStatus.new( :name => project_statuses(:test_project_status_one).name )
    assert !project_status.valid?
  end
  
end
