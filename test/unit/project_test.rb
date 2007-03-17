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
  
end
