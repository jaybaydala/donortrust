require File.dirname(__FILE__) + '/../test_helper'

class CityTest < Test::Unit::TestCase
  fixtures :regions
  fixtures :cities

  def test_invalid_with_empty_region_id
    city = City.new
    assert !city.valid?
    assert city.errors.invalid?(:region_id)
  end
  
  def test_should_not_add_city_without_region
  
    city = City.new
    city.region_id = 0
    assert !city.save
  
  end
  
  def test_invalid_with_empty_name
    city = City.new
    assert !city.valid?
    assert city.errors.invalid?(:city_name)
  end
  
  def test_unique_name
    city = City.new( :city_name => cities(:one).city_name )
    assert city.valid?
  end
end
