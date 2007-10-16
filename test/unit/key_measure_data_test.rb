require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::KeyMeasureDataTest < Test::Unit::TestCase
fixtures :key_measure_datas
  context "Key Measure data Tests " do
      
    specify "should create a key measure data" do
      KeyMeasureData.should.differ(:count).by(1) {create_key_measure} 
    end     
    
    specify "should require date" do
      lambda {
        t = create_key_measure(:date => nil)
        t.errors.on(:date).should.not.be.nil
      }.should.not.change(KeyMeasureData, :count)
    end
    
    specify "should require value" do
      lambda {
        t = create_key_measure(:value => nil)
        t.errors.on(:value).should.not.be.nil
      }.should.not.change(KeyMeasureData, :count)
    end
   
    specify "should require key_measure_id" do
      lambda {
        t = create_key_measure(:key_measure_id => nil)
        t.errors.on(:key_measure_id).should.not.be.nil
      }.should.not.change(KeyMeasureData, :count)
    end
   
    def create_key_measure(options = {})
      KeyMeasureData.create({ :key_measure_id => 1, :value => 'Test Value', :comment => 'Test Comment', :date => '2007-10-15' }.merge(options))  
    end                                                          
  end
end
