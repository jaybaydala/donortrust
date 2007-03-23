require File.dirname(__FILE__) + '/../test_helper'

class ProjectCategoryTest < Test::Unit::TestCase
  fixtures :project_categories

  def test_invalid_with_empty_description
    project_category = ProjectCategory.new
    assert !project_category.valid?
    assert project_category.errors.invalid?(:description)
  end
  
  def test_unique_description
    project_category = ProjectCategory.new( :description => project_categories(:test_project_category_one).description )
    assert !project_category.valid?
  end
  
end
