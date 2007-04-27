require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < Test::Unit::TestCase
  fixtures :milestones, :task_statuses, :task_categories, :tasks

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :milestone_id => milestones( :one ).id,
      :title => "clean task instance title",
      :task_category_id => task_categories( :testone ).id,
      :task_status_id => task_statuses( :proposed ).id,
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
    old_hist_count = TaskHistory.count
    # Saving a brand new instance should create both a Task and TaskHistory 'record'
    instance = clean_new_instance
    assert_valid instance
    instance.save
    assert_equal old_task_count+1, Task.count, "Task Count #{old_task_count+1} expect but was #{Task.count}"
    assert_equal old_hist_count+1, TaskHistory.count, "TaskHistory Count #{old_hist_count+1} expect but was #{TaskHistory.count}"
    # Each of the fixture instances should be valid
    assert_valid( Task.find( tasks( :taskone ).id ))
    assert_valid( Task.find( tasks( :tasktwo ).id ))
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

  def test_create_with_empty_title
    # Should not be valid to create a new instance with an empty or null title
    assert_invalid( clean_new_instance, :title, nil, "", " " )
  end

  def test_create_with_short_description
    # Should not be valid to create a new instance with an empty or blank description,
    # or one that is fewer the 15 characters long
    assert_invalid( clean_new_instance, :description, nil, "", " ", "description234" )
  end

  def test_edit_to_empty_milestone
    # Should not be valid to modify an existing instance to have a null milestone id, or an id that does not exist
    assert_invalid( Task.find( tasks( :taskone ).id ), :milestone_id, nil, 0, -1, 989898 )
  end

  def test_edit_to_empty_status
    # Should not be valid to modify an existing instance to have a null status id, or an id that does not exist
    assert_invalid( Task.find( tasks( :taskone ).id ), :task_status_id, nil, 0, -1, 989898 )
  end

  def test_edit_to_empty_category
    # Should not be valid to modify an existing instance to have a null category id, or an id that does not exist
    assert_invalid( Task.find( tasks( :taskone ).id ), :task_category_id, nil, 0, -1, 989898 )
  end

  def test_edit_to_empty_title
    # Should not be valid to modify an existing instance to have an empty or null title
    assert_invalid( Task.find( tasks( :taskone ).id ), :title, nil, "", " " )
  end

  def test_edit_to_short_description
    # Should not be valid to modify an existing instance to have an empty or blank description
    # or one that is fewer the 15 characters long
    assert_invalid( Task.find( tasks( :taskone ).id ), :description, nil, "", " ", "description234" )
  end

  def test_create_with_minimum_description
    # Should be valid to create a new instance that is 'just' the minimum description length
    # Saving a brand new instance should create both a Task and TaskHistory 'record'
    old_task_count = Task.count
    old_hist_count = TaskHistory.count
    instance = clean_new_instance
    instance.description = "description2345"
    assert_valid( instance )
    instance.save
    assert_equal old_task_count+1, Task.count, "Task Count #{old_task_count+1} expect but was #{Task.count}: #{instance.errors.inspect}"
    assert_equal old_hist_count+1, TaskHistory.count, "TaskHistory Count #{old_hist_count+1} expect but was #{TaskHistory.count}"
  end

  def test_edit_to_minimum_description
    # Should be valid to modify an existing instance to 'just' the minimum description length
    # Updating an existing instance should create a new TaskHistory instance
    old_task_count = Task.count
    old_hist_count = TaskHistory.count
    instance = Task.find( tasks( :taskone ).id )
    old_versions_count = instance.task_histories.count
    instance.description = "description2345"
    assert_valid( instance )
    instance.save
    assert_equal old_task_count, Task.count, "Task Count #{old_task_count} expect but was #{Task.count}"
    assert_equal old_hist_count+1, TaskHistory.count, "TaskHistory Count #{old_hist_count+1} expect but was #{TaskHistory.count}"
    assert_equal old_versions_count+1, instance.task_histories.count, "Changes count #{old_versions_count+1} expected but was #{instance.task_histories.count}"
  end

  #hpd need test(s) using update_attributes, since called by controller, and may be
  #overriding to check for no modification
  def test_update_to_minimum_description
    old_task_count = Task.count
    old_hist_count = TaskHistory.count
    instance = Task.find( tasks( :taskone ).id )
    old_versions_count = instance.task_histories.count
    instance.update_attributes({ :description => "description2345" })
    assert instance.errors.empty?, "#Update has unexpected errors {instance.errors.full_messages}"
    assert_equal old_task_count, Task.count, "Task count #{old_task_count} expect but was #{Task.count}"
    assert_equal old_hist_count+1, TaskHistory.count, "TaskHistory count #{old_hist_count+1} expected but was #{TaskHistory.count}"
    assert_equal old_versions_count+1, instance.task_histories.count, "Changes count #{old_versions_count+1} expected but was #{instance.task_histories.count}"
  end

  def test_nochange_update
    old_task_count = Task.count
    old_hist_count = TaskHistory.count
    instance = Task.find( tasks( :taskone ).id )
    old_versions_count = instance.task_histories.count
    instance.update_attributes( tasks( :taskone ).attributes )
    assert_equal instance.errors.count, 1, "Errors count 1 expected but was #{instance.errors.count} !! #{instance.errors.full_messages}"
    assert_equal instance.errors.on_base, "No change; Task instance update rejected", "No change message expected, was #{instance.errors.on_base.inspect}"
    assert_equal old_task_count, Task.count, "Task Count #{old_task_count} expect but was #{Task.count}"
    assert_equal old_hist_count, TaskHistory.count, "TaskHistory Count #{old_hist_count} expect but was #{TaskHistory.count}"
    assert_equal old_versions_count, instance.task_histories.count, "Changes count #{old_versions_count} expected but was #{instance.task_histories.count}"
  end

  #destroy should fail if any history for Task (or delete the history too)
end