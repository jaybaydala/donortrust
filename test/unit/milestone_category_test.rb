require File.dirname(__FILE__) + '/../test_helper'

class MilestoneCategoryTest < Test::Unit::TestCase
  fixtures :milestone_categories

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :category => "xyzcategoryxyz",
      :description => "Valid description for category"
    }.merge( overrides )
    MilestoneCategory.new( opts )
    # :id is a protected attribute.  Must set after creating instance
  end

  def test_clean_instance
    # Should be valid to create a new instance from the 'clean' instance created
    # by the helper function.
    assert_valid clean_new_instance
  end

  def test_create_with_empty_category
    # Should not be valid to create a new instance with an empty or blank category
    assert_invalid( clean_new_instance, :category, nil, "" )
  end
  
  def test_create_with_empty_description
    # Should not be valid to create a new instance with an empty or blank description
    assert_invalid( clean_new_instance, :description, nil, "" )
  end
  
  def test_unique_create_category
    # Should not be valid to reuse an existing category to create a new instance
    assert_invalid( clean_new_instance, :category, milestone_categories( :testone ).category )
  end
  
  def test_edit_to_empty_category
    # Should not be valid to modify an existing instance to have an empty or blank category
    assert_valid( MilestoneCategory.find( milestone_categories( :testone ).id ))
    assert_invalid( MilestoneCategory.find( milestone_categories( :testone ).id ), :category, nil, "" )
  end

  def test_edit_to_empty_description
    # Should not be valid to modify an existing instance to have an empty or blank description
    assert_invalid( MilestoneCategory.find( milestone_categories( :testone ).id ), :description, nil, "" )
  end

  def test_edit_to_duplicate_category
    # Should not be valid to modify an existing instance to have a category that
    # matches (duplicated) another existing instance.
    assert_invalid( MilestoneCategory.find( milestone_categories( :testone ).id ), 
      :category, milestone_categories( :testtwo ).category  )
  end
  #destroy should fail if any Milestone (or history) using category
end
