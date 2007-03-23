require File.dirname(__FILE__) + '/../test_helper'

class VillageTest < Test::Unit::TestCase
  fixtures :village_groups
  fixtures :villages

 def test_invalid_with_empty_village_group_id
    village = Village.new
    assert !village.valid?
    assert village.errors.invalid?(:village_group_id)
  end
  
  def test_should_not_add_village_without_village_group
  
    village = Village.new
    village.village_group_id = 0
    assert !village.save
  
  end
  
  def test_invalid_with_empty_name
    village = Village.new
    assert !village.valid?
    assert village.errors.invalid?(:village_name)
  end
  
  def test_unique_name
    village = Village.new( :village_name => Villages(:village_one).village_name )
    assert village.valid?
  end
end
