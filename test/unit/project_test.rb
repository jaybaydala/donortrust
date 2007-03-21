require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < Test::Unit::TestCase
  fixtures :projects

  def test_invalid_with_empty_name
    project = Project.new
    assert !project.valid?
    assert project.errors.invalid?(:name)
  end
  
  def test_unique_name
    project = Project.new( :name => projects(:project_one).name )
    assert !project.valid?
  end
  
  def test_save_with_audit_done_with_project_history_creation
    project = Project.new( :name => projects(:project_one).name + "-1" )
    result = project.save_with_audit
    assert result
    
    saved_project = Project.find(project.id)
    assert_not_nil saved_project.project_histories
    assert_not_nil ProjectHistory.find_all_by_project_id(saved_project.id)
    
    project_histories_from_saved_project = saved_project.project_histories
    puts project_histories_from_saved_project.class
    assert_equal 1, project_histories_from_saved_project.size
    saved_project_histories = ProjectHistory.find_all_by_project_id(saved_project.id)
    assert_equal 1, saved_project_histories.size
    
    project_history_from_saved_project = project_histories_from_saved_project[0]
    saved_project_history = saved_project_histories[0]
    assert_equal project_history_from_saved_project, saved_project_history
    
    assert_equal project.expected_completion_date, project_history_from_saved_project.expected_completion_date
    assert_equal project.status_id, project_history_from_saved_project.status_id
  end
  
  def test_is_a_project
    
    assert Project.is_a_project?( projects(:project_one) )
    assert !Project.is_a_project?( "Test String" )
    
  end
  
end
