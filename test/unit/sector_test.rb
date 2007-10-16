require File.dirname(__FILE__) + '/../test_helper'

#class BusAdmin::SectorTest < Test::Unit::TestCase

  context "Sectors" do
    fixtures :sectors
  
    specify "should create a sector" do
      Sector.should.differ(:count).by(1) { create_sector } 
    end
  
    specify "should require name" do
      lambda {
        t = create_sector(:name => nil)
        t.errors.on(:name).should.not.be.nil
      }.should.not.change(Sector, :count)
    end
      
    specify "name should be unique" do
      @sector = create_sector()
      @sector.save
      @sector = create_sector()
      @sector.should.not.validate
    end   
    
    def create_sector(options = {})
      Sector.create({ :name => 'Test', :description =>'description' }.merge(options))  
    end
  end
#end
