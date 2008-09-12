require File.dirname(__FILE__) + '/../test_helper'

context "Key Measure data Tests " do
  fixtures :key_measures, :key_measure_datas, :projects, :measures, :millennium_goals
    
  specify "should create some key measure data" do
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
    KeyMeasureData.create({ :key_measure_id => 1, :value => 1, :comment => 'Test', :date => '2007-10-31' }.merge(options))  
  end                                                          
end
