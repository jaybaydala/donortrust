require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::PlaceSectorTest < Test::Unit::TestCase
 fixtures :place_sectors, :places, :sectors

 context "Place Sector Tests " do
    
    specify "should create place sector" do
      PlaceSector.should.differ(:count).by(1) {create_place_sector} 
    end 
 
    specify "should require place id" do
      lambda {
        t = create_place_sector(:place_id => nil)
        t.errors.on(:place_id).should.not.be.nil
      }.should.not.change(PlaceSector, :count)
   end
   
   specify "should require sector" do
      lambda {
        t = create_place_sector(:sector_id => nil)
        t.errors.on(:sector_id).should.not.be.nil
      }.should.not.change(PlaceSector, :count)
    end
   
  def create_place_sector(options = {})
      PlaceSector.create({ :place_id => 1, :sector_id => 1 }.merge(options))  
    end                                                          
  end
end