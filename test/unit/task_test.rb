require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < Test::Unit::TestCase
  fixtures :milestones, :tasks

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :milestone_id => milestones( :one ).id,
      :name => "clean task instance name",
      :description => "clean task instant description"
    }.merge( overrides )
    instance = Task.new( opts )
    # :milestone_id is a protected attribute.  Must set [separately] after creating instance
    instance.milestone_id = opts[ :milestone_id ]
    instance
  end

  def test_clean_instance
    # Should be valid to create a new instance from the 'clean' instance created
    # by the helper function.
    old_task_count = Task.count
    instance = clean_new_instance
    assert_valid instance
    instance.save
    assert_equal old_task_count+1, Task.count, "Task Count #{old_task_count+1} expect but was #{Task.count}"
    # Each of the fixture instances should be valid
    assert_valid( Task.find( tasks( :taskone ).id ))
    assert_valid( Task.find( tasks( :tasktwo ).id ))
  end

  def test_create_with_empty_milestone
    # Should not be valid to create a new instance with a null milestone id, or an id that does not exist
    assert_invalid( clean_new_instance, :milestone_id, nil, 0, -1, 989898 )
  end

  def test_create_with_empty_name
    # Should not be valid to create a new instance with an empty or null name
    assert_invalid( clean_new_instance, :name, nil, "", " " )
  end

  def test_create_with_empty_description
    # Should not be valid to create a new instance with an empty or blank description
    assert_invalid( clean_new_instance, :description, nil, "", " " )
  end

  def test_edit_to_empty_milestone
    # Should not be valid to modify an existing instance to have a null milestone id, or an id that does not exist
    assert_invalid( Task.find( tasks( :taskone ).id ), :milestone_id, nil, 0, -1, 989898 )
  end

  def test_edit_to_empty_name
    # Should not be valid to modify an existing instance to have an empty or null name
    assert_invalid( Task.find( tasks( :taskone ).id ), :name, nil, "", " " )
  end

  def test_edit_to_empty_description
    # Should not be valid to modify an existing instance to have an empty or blank description
    assert_invalid( Task.find( tasks( :taskone ).id ), :description, nil, "", " " )
  end
end