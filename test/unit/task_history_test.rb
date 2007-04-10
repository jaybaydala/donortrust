require File.dirname(__FILE__) + '/../test_helper'

class TaskHistoryTest < Test::Unit::TestCase
  fixtures :milestones, :task_statuses, :task_categories, :tasks, :task_histories

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :task_id => 1,
      :milestone_id => 1,
      :title => "clean task instance title",
      :task_category_id => 1,
      :task_status_id => 1,
      :description => "clean task instant description"
    }.merge( overrides )
    TaskHistory.new( opts )
    # :id is a protected attribute.  Must set after creating instance
  end

  def test_clean_instance
    # Should be valid to create a new instance from the 'clean' instance created
    # by the helper function.
    assert_valid clean_new_instance
    # Each of the fixture instances should be valid
    # hpd : should not be able to save
    assert_valid( TaskHistory.find( task_histories( :histone ).id ))
    assert_valid( TaskHistory.find( task_histories( :histtwo ).id ))
  end

  def test_create_with_empty_task
    # Should not be valid to create a new instance with a null task id, or an id that does not exist
    assert_invalid( clean_new_instance, :task_id, nil, 0, -1, 989898 )
  end

  def test_create_with_empty_milestone
    # Should not be valid to create a new instance with a null milestone id, or an id that does not exist
    assert_invalid( clean_new_instance, :milestone_id, nil, 0, -1, 989898 )
  end

  def test_create_with_empty_status
    # Should not be valid to create a new instance with a null status id, or an id that does not exist
    assert_invalid( clean_new_instance, :task_status_id, nil, 0, -1, 989898 )
  end

  def test_create_with_empty_category
    # Should not be valid to create a new instance with a null category id, or an id that does not exist
    assert_invalid( clean_new_instance, :task_category_id, nil, 0, -1, 989898 )
  end

  def test_create_with_empty_created_at
    # Should not be valid to create a new instance with a null creation time stamp
    # hpd : is valid? autocreate on save?
    assert_invalid( clean_new_instance, :created_at, nil )
  end

  def test_create_with_empty_title
    # Should not be valid to create a new instance with an empty or null title
    assert_invalid( clean_new_instance, :title, nil, "", " " )
  end

  def test_create_with_short_description
    # Should not be valid to create a new instance with an empty or blank description,
    # or one that is fewer the 15 characters long
    assert_invalid( clean_new_instance, :description, nil, "", " ", "description234" )
  end

  def test_edit_any
    # Should not be valid to modify an existing instance.  Unmodifiable audit trail.
    assert_invalid( TaskHistory.find( task_histories( :histone ).id ), :task_id, nil, 0, -1, 989898 )
  end

  def test_create_with_minimum_description
    # Should be valid to create a new instance that is 'just' the minimum description length
    assert_valid( clean_new_instance, :description, "description2345" )
  end

  #destroy should fail (always?) : what about extract / archive?
  #- only do from database, not from model?
end
