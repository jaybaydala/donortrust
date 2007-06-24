require File.dirname(__FILE__) + '/../test_helper'

class MilestoneStatusTest < Test::Unit::TestCase
  fixtures :milestone_statuses

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :name => "xyzstatusxyz",
      :description => "Valid description for status"
    }.merge( overrides )
    MilestoneStatus.new( opts )
    # :id is a protected attribute.  Must set after creating instance
  end

  def test_clean_instance
    # Should be valid to create a new instance from the 'clean' instance created
    # by the helper function.
    assert_valid clean_new_instance
  end

  def test_create_with_empty_name
    # Should not be valid to create a new instance with an empty or blank name
    assert_invalid( clean_new_instance, :name, nil, "" )
  end
  
  def test_create_with_empty_description
    # Should not be valid to create a new instance with an empty or blank description
    assert_invalid( clean_new_instance, :description, nil, "" )
  end
  
  def test_unique_create_name
    # Should not be valid to reuse an existing name to create a new instance
    assert_invalid( clean_new_instance, :name, milestone_statuses( :proposed ).name )
  end
  
  def test_edit_to_empty_name
    # Should not be valid to modify an existing instance to have an empty or blank name
    assert_valid( MilestoneStatus.find( milestone_statuses( :proposed ).id ))
    assert_invalid( MilestoneStatus.find( milestone_statuses( :proposed ).id ), :name, nil, "" )
  end

  def test_edit_to_empty_description
    # Should not be valid to modify an existing instance to have an empty or blank description
    assert_invalid( MilestoneStatus.find( milestone_statuses( :proposed ).id ), :description, nil, "" )
  end

  def test_edit_to_duplicate_name
    # Should not be valid to modify an existing instance to have a name that
    # matches (duplicated) another existing instance.
    assert_invalid( MilestoneStatus.find( milestone_statuses( :proposed ).id ), 
      :name, milestone_statuses( :inprogress ).name  )
  end
  #destroy should fail if any Milestone (or history) using status
end
