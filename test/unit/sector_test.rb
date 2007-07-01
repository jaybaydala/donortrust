require File.dirname(__FILE__) + '/../test_helper'


context "Sectors" do
  fixtures :sectors

setup do
    @sector = Sector.find(1)
  end
 
  specify "The sector should have a name & description" do
    @sector.name.should.not.be.nil
    @sector.description.should.not.be.nil
  end


specify "duplicate name should not validate" do
    @sector1 = Sector.new( :name => @sector.name, :description =>  "This should be invalid" )
    
    @sector1.should.not.validate
    
end
specify "nil name should not validate" do
    @sector.name = nil
    @sector.should.not.validate
  end
  
  specify "nil description should not validate" do
    @sector.description = nil
    @sector.should.not.validate
  end

end