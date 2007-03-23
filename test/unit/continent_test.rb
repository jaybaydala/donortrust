require File.dirname(__FILE__) + '/../test_helper'

class ContinentTest < Test::Unit::TestCase
  fixtures :continents

  def test_invalid_with_empty_name
    continent = Continent.new
    assert !continent.valid?
    assert continent.errors.invalid?(:continent_name)
  end
  
  def test_unique_name
    continent = Continent.new( :continent_name => continents(:continent_one).continent_name )
    assert !continent.valid?
  end
  
end
