require File.dirname(__FILE__) + '/../test_helper'

class VillageGroupTest < Test::Unit::TestCase
  fixtures :regions
  fixtures :village_groups

  def test_invalid_with_empty_region_id
    villageGroup = VillageGroup.new
    assert !villageGroup.valid?
    assert villageGroup.errors.invalid?(:region_id)
  end
  
  def test_should_not_add_village_group_without_region
  
    vilageGroup = VillageGroup.new
    villageGroup.region_id = 0
    assert !villageGroup.save
  
  end
  
  def test_invalid_with_empty_name
    villageGroup = VillageGroup.new
    assert !villageGroup.valid?
    assert villageGroup.errors.invalid?(:village_group_name)
  end
  
  def test_unique_name
    villageGroup = VillageGroup.new( :village_group_name => village_groups(:village_groups_one).village_group_name )
    assert villageGroup.valid?
  end
end
