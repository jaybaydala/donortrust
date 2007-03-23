require File.dirname(__FILE__) + '/../test_helper'

class RegionTest < Test::Unit::TestCase
  fixtures :nations
  fixtures :regions

  def test_invalid_with_empty_nation_id
    region = Region.new
    assert !region.valid?
    assert region.errors.invalid?(:nation_id)
  end
  
  def test_should_not_add_region_without_nation
  
    region = region.new
    region.nation_id = 0
    assert !region.save
  
  end
  
  def test_invalid_with_empty_name
    region = Region.new
    assert !region.valid?
    assert region.errors.invalid?(:region_name)
  end
  
  def test_unique_name
    region = Region.new( :region_name => nations(:region_one).region_name )
    assert region.valid?
  end
end
