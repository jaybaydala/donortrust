require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::QuickFactPartnerTest < Test::Unit::TestCase
  fixtures :quick_fact_partners

  context "Quick Fact Partner Tests " do
    
    specify "should create a quick fact partner" do
      QuickFactPartner.should.differ(:count).by(1) {create_quick_fact} 
    end 
 
    specify "should require quick_fact" do
      lambda {
        t = create_quick_fact(:quick_fact => nil)
        t.errors.on(:quick_fact).should.not.be.nil
      }.should.not.change(QuickFactPartner, :count)
    end
   
    specify "should require partner" do
      lambda {
        t = create_quick_fact(:partner => nil)
        t.errors.on(:partner).should.not.be.nil
      }.should.not.change(QuickFactPartner, :count)
    end
   
    def create_quick_fact(options = {})
      QuickFactPartner.create({ :quick_fact_id => 1, :description => 'My Description', :partner_id => 1 }.merge(options))  
    end                                                          
  end
end