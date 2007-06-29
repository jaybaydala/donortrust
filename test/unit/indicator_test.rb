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

end
