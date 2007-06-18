require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::ProjectTest < Test::Unit::TestCase
  fixtures :projects, :milestones

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_percent_raised
    project = Project.find(:first)
    project.total_cost = 100
    project.dollars_raised = 45
    expected = 45
    assert_equal expected, project.get_percent_raised
  end
  
  def test_percent_raised_no_cost
    project = Project.find(:first)
    project.total_cost = 0
    project.dollars_raised = 45
    assert_equal nil, project.get_percent_raised
  end
  
  def test_days_remaining #need to mock out time.now
    project = Project.find(:first)
    project.end_date = '2007-08-08'
    #Time.now = '2007-08-02'
    #assert_equal @project.days_remaining, 6
  end
  
  def test_started_projects
    assert_equal 2, Project.find(:all).size
    assert_equal 1, Project.find(:all, :conditions => "project_status_id = 2").size
  end
  
  def test_total_milestones
    assert_equal 4, Project.find(1).milestones.find(:all).size
  end
    
  def test_get_milestones_by_status
    project = Project.find(1)
    milestones = project.get_milestones_by_status(3)
    puts milestones.size
    assert_equal 1, milestones.size
  end
end
