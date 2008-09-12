require File.dirname(__FILE__) + '/../test_helper'

context "Quick Fact PlacesTests " do
  fixtures :quick_fact_places
  
  specify "should create a quick fact place" do
    QuickFactPlace.should.differ(:count).by(1) {create_quick_fact} 
  end     

  specify "should require quick_fact" do
    lambda {
      t = create_quick_fact(:quick_fact_id => nil)
      t.errors.on(:quick_fact_id).should.not.be.nil
    }.should.not.change(QuickFactPlace, :count)
  end
 
  specify "should require place" do
    lambda {
      t = create_quick_fact(:place_id => nil)
      t.errors.on(:place_id).should.not.be.nil
    }.should.not.change(QuickFactPlace, :count)
  end
 
  def create_quick_fact(options = {})
    QuickFactPlace.create({ :quick_fact_id => 1, :description => 'My Description', :place_id => 1 }.merge(options))  
                                       
  end                                                          
end
