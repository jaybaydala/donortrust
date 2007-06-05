require File.dirname(__FILE__) + '/../test_helper'

class RegionTypeTest < Test::Unit::TestCase
  fixtures :region_types

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :region_type_name => "xyztypexyz"
    }.merge( overrides )
    RegionType.new( opts )
    # :id is a protected attribute.  Must set after creating instance
  end

  def test_clean_instance
    # Should be valid to create a new instance from the 'clean' instance created
    # by the helper function.
    assert_valid clean_new_instance
  end

  def test_create_with_empty_type
    # Should not be valid to create a new instance with an empty or blank type
    assert_invalid( clean_new_instance, :region_type_name, nil, "" )
  end
  
  def test_unique_create_type
    # Should not be valid to reuse an existing type to create a new instance
    assert_invalid( clean_new_instance, :region_type_name, region_types( :testone ).region_type_name )
  end
  
  def test_edit_to_empty_type
    # Should not be valid to modify an existing instance to have an empty or blank type
    assert_valid( RegionType.find( region_types( :testone ).id ))
    assert_invalid( RegionType.find( region_types( :testone ).id ), :region_type_name, nil, "" )
  end

  def test_edit_to_duplicate_type
    # Should not be valid to modify an existing instance to have a status that
    # matches (duplicated) another existing instance.
    assert_invalid( RegionType.find( region_types( :testone ).id ), 
      :region_type_name, region_types( :testtwo ).region_type_name  )
  end
end
