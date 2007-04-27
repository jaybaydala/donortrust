require File.dirname(__FILE__) + '/../test_helper'

class TaskHistoryTest < Test::Unit::TestCase
  fixtures :milestones, :task_statuses, :task_categories, :tasks, :task_histories

  #hpd With structure changes for Task and TaskHistory, this needs a total rewrite.
  #hpd Things that were previously invalid, are now valid, number of aruments for
  #hpd save have changed back to the defaults, new instance MUST be created from
  #hpd existing Task instance (not from hash of fields).
  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    TaskHistory.new( tasks( :taskone ), overrides )
    # :id is a protected attribute.  Must set after creating instance
  end

  def test_clean_instance
    # Should be valid to create a new instance from the 'clean' instance created
    # by the helper function.
    assert_valid clean_new_instance
    # Each of the fixture instances should be valid
    # Should not be able to save the loaded instances, so can not use the assert_valid
    # helper function.
    assert_valid( TaskHistory.find( task_histories( :histone ).id ))
    assert_valid( TaskHistory.find( task_histories( :histtwo ).id ))
    #instance = TaskHistory.find( task_histories( :histone ).id )
    #assert instance.valid?, "#{instance.class} :histone instance invalid; #{instance.errors.full_messages.inspect}"
    # hmmmm? The processing done by .valid? runs validate_on_update if not new_record?, so the following
    # assert fails.  *could* try reseting @new_record to true with some tricks, but that would just cause
    # any new record unique value tests to fail.  Just attempt to do the save, to verify that it fails,
    # without attempting to validate the [just loaded] data first.
    #begin
    #  instance.save
    #  assert false, "#{instance.class} :histone no argument save did not raise exception"
    #rescue ArgumentError => e
    #  assert ( e.message == "wrong number of arguments (0 for 1)" ), "dump exception |#{e.message}|"
    #end
    #assert !instance.save( tasks( :taskone )), "#{instance.class} :histone instance save successful"
    # assert instance.errors.empty?, "#{instance.class} :histone instance errors; #{instance.errors.full_messages}"
    #instance = TaskHistory.find( task_histories( :histtwo ).id )
    #assert !instance.save( tasks( :taskone )), "#{instance.class} :histtwo instance save successful"
  end

  def test_noargs_for_new
    #Exception: wrong number of arguments (0 for 1)
    #C:\Data\DonorTrust\dt20070407/test/unit/task_history_test.rb:34:in `initialize'
    #C:\Data\DonorTrust\dt20070407/test/unit/task_history_test.rb:34:in `new'
    #Above is the correct (raised) error for using TaskHistory.new with no arguments
    begin
      instance = TaskHistory.new
      assert false, "Created new TaskHistory instance without passing arguments"
    rescue ArgumentError => e
      assert ( e.message == "wrong number of arguments (0 for 1)" ), "dump exception |#{e.message}|"
    end
  end

  def test_create_with_empty_task
    # Should not be valid to create a new instance with a null task id, or an id that does not exist
    # hpd: with latest model, is valid to create/save with nil task_id.  The task ID will be copied
    # from the (required) Task instance passed to TaskHistory save
    # hpd: next problem is that assert_invalid invokes save without any parameters 
    assert_invalid_1( clean_new_instance, tasks( :taskone ), :task_id, nil, 0, -1, 989898 )
  end

  def test_create_with_empty_milestone
    # Should not be valid to create a new instance with a null milestone id, or an id that does not exist
    assert_invalid( clean_new_instance, :milestone_id, nil, 0, -1, 989898 )
  end

  def test_create_with_empty_status
    # Should not be valid to create a new instance with a null status id, or an id that does not exist
    assert_invalid_1( clean_new_instance, tasks( :taskone ), :task_status_id, nil, 0, -1, 989898 )
  end

  def test_create_with_empty_category
    # Should not be valid to create a new instance with a null category id, or an id that does not exist
    # hpd: would not be valid to save, but currently shows as valid?
    # The validations from Task are not checked until .save is running
    assert_invalid_1( clean_new_instance, tasks( :taskone ), :task_category_id, nil, 0, -1, 989898 )
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
    instance = TaskHistory.find( task_histories( :histone ).id )
    instance.task_id = nil
    assert_invalid_1( instance, tasks( :taskone ))
  end

  def test_create_with_minimum_description
    # Should be valid to create a new instance that is 'just' the minimum description length
    assert_valid( clean_new_instance, :description, "description2345" )
  end

  #destroy should fail (always?) : what about extract / archive?
  #- only do from database, not from model?
end
