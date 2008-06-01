require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::QuickFactSectorTest < Test::Unit::TestCase
  fixtures :quick_fact_sectors

 context "Quick Fact Sector Tests " do
   
   specify "should create a quick fact sector" do
      QuickFactSector.should.differ(:count).by(1) {create_quick_fact} 
    end
     
    specify "should require quick_fact" do
      lambda {
        t = create_quick_fact(:quick_fact_id => nil)
        t.errors.on(:quick_fact_id).should.not.be.nil
      }.should.not.change(QuickFactSector, :count)
   end
   
   specify "should require sector" do
      lambda {
        t = create_quick_fact(:sector_id => nil)
        t.errors.on(:sector_id).should.not.be.nil
      }.should.not.change(QuickFactSector, :count)
    end
   
  def create_quick_fact(options = {})
      QuickFactSector.create({ :quick_fact_id => 1, :description => 'My Description', :sector_id => 1 }.merge(options))  
                                         
    end                                                          
  end
end
