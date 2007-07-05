require File.dirname(__FILE__) + '/../test_helper'

context "UrbanCentres" do
  fixtures :urban_centres, :regions, :countries

  def setup    
    @fixture_urban_centre = UrbanCentre.find(:first)
  end
  
  specify "The urban centre should have a name & region id" do
    @fixture_urban_centre.name.should.not.be.nil
    @fixture_urban_centre.region_id.should.not.be.nil
  end
  
  specify "The urban centre should have a country" do
    region = Region.find(@fixture_urban_centre.region_id)
    region.country_id.should.not.be.nil
    #country = Country.find(region.country_id)
    #puts country.to_label
  end
end
