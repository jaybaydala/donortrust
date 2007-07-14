require File.dirname(__FILE__) + '/../test_helper'
context "Measurements" do
  fixtures :measurements

  setup do
    @measurement = Measurement.find(1)
  end
 
  specify "The measurement should have a indicator_measurement_id and & value" do
    @measurement.indicator_measurement_id.should.not.be.nil
    @measurement.value.should.not.be.nil
  end


  specify "nil indicator_measurement_id should not validate" do
    @measurement.indicator_measurement_id = nil
    @measurement.should.not.validate
  end
  
  specify "nil value should not validate" do
    @measurement.value = nil
    @measurement.should.not.validate
  end
end
