require File.dirname(__FILE__) + '/../spec_helper'

describe PlaceType do
  before do
    @place_type = PlaceType.generate!
  end
  after do
  end
  it "should create a record" do
    lambda{PlaceType.generate!}.should change(PlaceType, :count).by(1)
  end
  it "should validate_presence_of name" do
    @place_type.should validate_presence_of(:name)
  end
  it "should validate_uniqueness_of name" do
    @place_type.should validate_uniqueness_of(:name)
  end
  
  describe "specific record methods" do
    %w[ continent country state district region city ].each do |pt|
      it "should find a #{pt}" do
        PlaceType.send!(pt.to_s).should == PlaceType.find(:first, :conditions => ["name LIKE ?", pt])
      end
    end
    it "should alias city as community" do
      PlaceType.community.should == PlaceType.find(:first, :conditions => ["name LIKE ?", "city"])
    end
    it "should alias country as nation" do
      PlaceType.nation.should == PlaceType.find(:first, :conditions => ["name LIKE ?", "country"])
    end
  end
end
