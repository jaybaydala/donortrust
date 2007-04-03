require File.dirname(__FILE__) + '/../test_helper'

class MilestoneTest < Test::Unit::TestCase
  #fixtures :measures
  fixtures :milestone_statuses, :milestone_categories, :projects, :milestones

  def clean_new_milestone( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :project_id => 1,
      :milestone_category_id => 1,
      :milestone_status_id => 1,
      :measure_id => 1,
      :target_date => "2007-08-01",
      :description => "test valid milestone description"
    }.merge( overrides )
    Milestone.new( opts )
    # :id is a protected attribute.  Must set after creating instance
  end

  def test_clean_milestone
    # Should be valid to create a new instance from the 'clean' instance created
    # by the helper function.
    assert_valid clean_new_milestone
  end

  def test_create_with_empty_status
    # Should not be valid to create a new instance with a null status id, or an id that does not exist
    assert_invalid( clean_new_milestone({ :project_id => nil }), :milestone_status_id, 0, -1, 989898 )
    #assert_invalid( clean_new_milestone, :milestone_status_id, nil, 0, -1, 989898 )
  end
  
  def test_create_with_empty_category
    # Should not be valid to create a new instance with a null category id
    assert_invalid( clean_new_milestone, :milestone_category_id, nil, 0, -1, 989898 )
  end
  
  def test_create_with_empty_description
    # Should not be valid to create a new instance with an empty or blank description
    assert_invalid( clean_new_milestone, :description, nil, "" )
  end
  
  def test_edit_to_empty_status
    # Should not be valid to modify an existing instance to have a null status id, or an id that does not exist
    assert_valid( Milestone.find( milestones( :one ).id ))
    assert_invalid( Milestone.find( milestones( :one ).id ), :milestone_status_id, nil, 0, -1, 989898 )
  end

  def test_edit_to_empty_category
    # Should not be valid to modify an existing instance to have a null category id, or an id that does not exist
    assert_invalid( Milestone.find( milestones( :one ).id ), :milestone_category_id, nil, 0, -1, 989898 )
  end

  def test_edit_to_empty_description
    # Should not be valid to modify an existing instance to have an empty or blank status
    assert_invalid( Milestone.find( milestones( :one ).id ), :description, nil, "" )
  end

  #destroy should fail if any history for Milestone (or delete the history too)
  #destroy should fail if any Task (or task history) using Milestone
end
