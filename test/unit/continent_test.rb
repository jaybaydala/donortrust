require File.dirname(__FILE__) + '/../test_helper'

context "Continents" do
  fixtures :continents

setup do
    @continents = Continent.find(1)
  end

specify "duplicate name should not validate" do
   @continents1 = Continent.new( :continent_name =>  @continents.continent_name )
    @continents1.should.not.validate
    
end
specify "nil name should not validate" do
    @continents.continent_name = nil
    @continents.should.not.validate
  end
  
 
end
