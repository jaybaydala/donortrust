require File.dirname(__FILE__) + '/../test_helper'

context "CountrySectors" do
  fixtures :country_sectors, :sectors, :countries#, :continents

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  specify "modify existing record to nil country id should not validate" do
    old_instance_count = CountrySector.count
    instance = CountrySector.find( country_sectors( :one ).id )
    instance.country_id = nil
    instance.should.not.validate
    instance.save.should.equal( false )
    CountrySector.count.should.equal( old_instance_count )
  end

  specify "modify existing record to 0 country id should not validate" do
    old_instance_count = CountrySector.count
    instance = CountrySector.find( country_sectors( :one ).id )
    instance.country_id = 0
    instance.should.not.validate
    instance.save.should.equal( false )
    CountrySector.count.should.equal( old_instance_count )
  end

  specify "modify existing record to 98980 country id should not validate" do
    old_instance_count = CountrySector.count
    instance = CountrySector.find( country_sectors( :one ).id )
    instance.country_id = 98980
    instance.should.not.validate
    instance.save.should.equal( false )
    CountrySector.count.should.equal( old_instance_count )
  end

  specify "modify existing record to existing country id should validate" do
    old_instance_count = CountrySector.count
    instance = CountrySector.find( country_sectors( :one ).id )
    instance.country_id = countries( :test1 ).id
    instance.should.validate
    instance.save.should.equal( true )
    CountrySector.count.should.equal( old_instance_count )
  end

  specify "modify existing record to nil sector id should not validate" do
    old_instance_count = CountrySector.count
    instance = CountrySector.find( country_sectors( :one ).id )
    instance.sector_id = nil
    instance.should.not.validate
    instance.save.should.equal( false )
    CountrySector.count.should.equal( old_instance_count )
  end

  specify "modify existing record to 0 sector id should not validate" do
    old_instance_count = CountrySector.count
    instance = CountrySector.find( country_sectors( :one ).id )
    instance.sector_id = 0
    instance.should.not.validate
    instance.save.should.equal( false )
    CountrySector.count.should.equal( old_instance_count )
  end

  specify "modify existing record to 98980 sector id should not validate" do
    old_instance_count = CountrySector.count
    instance = CountrySector.find( country_sectors( :one ).id )
    instance.sector_id = 98980
    instance.should.not.validate
    instance.save.should.equal( false )
    CountrySector.count.should.equal( old_instance_count )
  end

  specify "modify existing record to existing sector id should validate" do
    old_instance_count = CountrySector.count
    instance = CountrySector.find( country_sectors( :one ).id )
    instance.sector_id = sectors( :one ).id
    instance.should.validate
    instance.save.should.equal( true )
    CountrySector.count.should.equal( old_instance_count )
  end

  specify "modify existing record to nil content should not validate" do
    old_instance_count = CountrySector.count
    instance = CountrySector.find( country_sectors( :one ).id )
    instance.content = nil
    instance.should.not.validate
    instance.save.should.equal( false )
    CountrySector.count.should.equal( old_instance_count )
  end
end
