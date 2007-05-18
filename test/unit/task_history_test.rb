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
    # HPD merge new value into reference fixture instance, to prevent no change exceptions
    instance = TaskHistory.new( tasks( :taskone ))
    instance.title = "new test title"
    overrides.each_pair { |attr, value| instance.send( "#{attr}=", value )}
    instance
  end

  def test_clean_instance
    # Should be valid to create a new instance from the 'clean' instance created
    # by the helper function (in not fail due to no change in attributes).
    assert_valid clean_new_instance
    # Each of the fixture instances should be valid 'as is'.  Code (is supposed to)
    # prevent updates to existing history instances, so should not be valid to [re]save
    # them.  That means the assert_valid helper function will fail.
    #assert_valid( TaskHistory.find( task_histories( :histone ).id ))
    #assert_valid( TaskHistory.find( task_histories( :histtwo ).id ))
    instance = TaskHistory.find( task_histories( :histone ).id )
    #assert instance.valid?, "#{instance.class} :histone instance invalid; #{instance.errors.full_messages.inspect}"
    # hmmmm? The processing done by .valid? runs validate_on_update if not new_record?, so the above
    # assert fails.  *could* try reseting @new_record to true with some tricks, but that would just cause
    # any new record unique value tests to fail.  Just attempt to do the save, to verify that it fails,
    # without attempting to validate the [just loaded] data first.
    assert_equal( instance.errors.count, 0, "pre-save histone errors count not 0: #{instance.inspect}")
    instance.save
    assert_equal( instance.errors.count, 1, "post-save histone error count not 1: #{instance.inspect}")
    assert_equal( instance.errors.on_base, "Update TaskHistory instance rejected", "Other histone error #{instance.errors.full_messages.inspect}" )
    # Repeat for other fixture
    instance = TaskHistory.find( task_histories( :histtwo ).id )
    assert_equal( instance.errors.count, 0, "pre-save histtwo errors count not 0: #{instance.inspect}")
    instance.save
    assert_equal( instance.errors.count, 1, "post-save histtwo error count not 1: #{instance.inspect}")
    assert_equal( instance.errors.on_base, "Update TaskHistory instance rejected", "Other histtwo error #{instance.errors.full_messages.inspect}" )
  end

  def test_noargs_for_new
    #Exception: wrong number of arguments (0 for 1)
    #<<project path>>/test/unit/task_history_test.rb:34:in `initialize'
    #<<project path>>/test/unit/task_history_test.rb:34:in `new'
    #Above is the correct (raised) error for using TaskHistory.new with no arguments
    begin
      instance = TaskHistory.new
      assert false, "Created new TaskHistory instance without passing arguments"
    rescue ArgumentError => e
      assert_equal( e.message, "wrong number of arguments (0 for 1)" , "dump exception |#{e.message}|" )
    end
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
    # hpd: would not be valid to save, but currently shows as valid?
    # The validations from Task are not checked until .save is running
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

  def test_edit_any
    # Should not be valid to modify an existing instance.  Unmodifiable audit trail.
    instance = TaskHistory.find( task_histories( :histone ).id )
    instance.task_id = nil
    assert_invalid( instance )
  end

  def test_create_with_minimum_description
    # Should be valid to create a new instance that is 'just' the minimum description length
    assert_valid( clean_new_instance, :description, "description2345" )
  end

  #destroy should fail (always?) : what about extract / archive?
  #- only do from database, not from model?
end
