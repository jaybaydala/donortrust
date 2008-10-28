require File.dirname(__FILE__) + '/../test_helper'


context "Partner Types Tests " do
  fixtures :partner_types
  
  specify "should create a partner type" do
    PartnerType.should.differ(:count).by(1) { create_partner_type } 
  end     

  specify "should require name" do
    lambda {
      t = create_partner_type(:name => nil)
      t.errors.on(:name).should.not.be.nil
    }.should.not.change(PartnerType, :count)
  end
 
  specify "should require description" do
    lambda {
      t = create_partner_type(:description => nil)
      t.errors.on(:description).should.not.be.nil
    }.should.not.change(PartnerType, :count)
  end
  
  specify "name should be less then 50 Characters" do
    lambda {
      t = create_partner_type(:name=> 'This will enter more then fifty characters into the column')
      t.errors.on(:name).should.not.be.nil
    }.should.not.change(PartnerType, :count)
  end
 
  def create_partner_type(options = {})
    PartnerType.create({ :name => 'Test Name', :description => 'My Description' }.merge(options))                          
  end                                                          
end
