require File.dirname(__FILE__) + '/../test_helper'

class MeasureTest < Test::Unit::TestCase
  fixtures :measure_categories, :measures

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :measure_category_id => 1,
      :quantity => 1,
      :measure_date => "2007-08-01",
      :user_id => 1
    }.merge( overrides )
    Measure.new( opts )
    # :id is a protected attribute.  Must set after creating instance
  end

  def test_clean_instance
    # Should be valid to create a new instance from the 'clean' instance created
    # by the helper function.
    assert_valid clean_new_instance
  end

  def test_create_with_empty_category
    # Should not be valid to create a new instance with a null category id, or an id that does not exist
    assert_invalid( clean_new_instance, :measure_category_id, nil, 0, -1, 989898 )
  end
  
  def test_edit_to_empty_category
    # Should not be valid to modify an existing instance to have a null category id, or an id that does not exist
    assert_invalid( Measure.find( measures( :one ).id ), :measure_category_id, nil, 0, -1, 989898 )
  end

  #destroy should fail if any Milestone (or history) for Measure
end
