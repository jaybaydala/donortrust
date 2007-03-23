require File.dirname(__FILE__) + '/../test_helper'

class NationTest < Test::Unit::TestCase
  fixtures :continents
  fixtures :nations

  def test_invalid_with_empty_continent_id
    nation = Nation.new
    assert !nation.valid?
    assert nation.errors.invalid?(:continent_id)
  end
  
  def test_should_not_add_nation_without_continent
  
    nation = nation.new
    nation.continent_id = 0
    assert !nation.save
  
  end
  
  def test_invalid_with_empty_name
    nation = Nation.new
    assert !nation.valid?
    assert nation.errors.invalid?(:nation_name)
  end
  
  def test_unique_name
    nation = Nation.new( :nation_name => nations(:nation_one).nation_name )
    assert continent.valid?
  end
end
