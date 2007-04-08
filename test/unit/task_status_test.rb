require File.dirname(__FILE__) + '/../test_helper'

class TaskStatusTest < Test::Unit::TestCase
  fixtures :task_statuses

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :status => "xyzstatusxyz",
      :description => "Valid description for status"
    }.merge( overrides )
    TaskStatus.new( opts )
    # :id is a protected attribute.  Must set after creating instance
  end

  def test_clean_instance
    # Should be valid to create a new instance from the 'clean' instance created
    # by the helper function.
    assert_valid clean_new_instance
  end

  def test_create_with_empty_status
    # Should not be valid to create a new instance with an empty or blank status
    assert_invalid( clean_new_instance, :status, nil, "" )
  end
  
  def test_create_with_empty_description
    # Should not be valid to create a new instance with an empty or blank description
    assert_invalid( clean_new_instance, :description, nil, "" )
  end
  
  def test_unique_create_status
    # Should not be valid to reuse an existing status to create a new instance
    assert_invalid( clean_new_instance, :status, task_statuses( :proposed ).status )
  end
  
  def test_edit_to_empty_status
    # Should not be valid to modify an existing instance to have an empty or blank status
    assert_valid( TaskStatus.find( task_statuses( :proposed ).id ))
    assert_invalid( TaskStatus.find( task_statuses( :proposed ).id ), :status, nil, "" )
  end

  def test_edit_to_empty_description
    # Should not be valid to modify an existing instance to have an empty or blank description
    assert_invalid( TaskStatus.find( task_statuses( :proposed ).id ), :description, nil, "" )
  end

  def test_edit_to_duplicate_status
    # Should not be valid to modify an existing instance to have a status that
    # matches (duplicated) another existing instance.
    assert_invalid( TaskStatus.find( task_statuses( :proposed ).id ), 
      :status, task_statuses( :inprogress ).status  )
  end
  #destroy should fail if any Task (or history) using status
end
