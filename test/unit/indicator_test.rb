require File.dirname(__FILE__) + '/../test_helper'
context "Indicators" do
  fixtures :indicators

  setup do
    @indicator = Indicator.find(1)
  end
 
  specify "The indicator should have a target_id and & description" do
    @indicator.target_id.should.not.be.nil
    @indicator.description.should.not.be.nil
  end

  specify "duplicate description should not validate" do
    @indictor1 = Indicator.new( :target_id => 1, :description =>  @indicator.description )
    @indictor1.should.not.validate
  end

  specify "nil target_id should not validate" do
    @indicator.target_id = nil
    @indicator.should.not.validate
  end
  
  specify "nil description should not validate" do
    @indicator.description = nil
    @indicator.should.not.validate
  end
end
