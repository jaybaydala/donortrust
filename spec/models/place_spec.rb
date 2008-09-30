require File.dirname(__FILE__) + '/../spec_helper'

describe Place do
  before do
    @place = Place.generate!
  end
  
  it "should create a place" do
    lambda{ Place.generate! }.should change(Place, :count).by(1)
  end
  it "should require name" do
    @place.should validate_presence_of(:name)
  end
  it "should require place_type_id" do
    @place.should validate_presence_of(:place_type_id)
  end
  # non-essential fields
  %w( parent_id description blog_url rss_url you_tube_reference flickr_reference facebook_group_id ).each do |field|
    it "should not require \"#{field}\"" do
      lambda{ Place.generate!({ field.to_s => nil }) }.should change(Place, :count).by(1)
    end
  end
  it "should require facebook_group_id to be numerical" do
    @place.update_attributes(:facebook_group_id => "hithere")
    @place.errors.on(:facebook_group_id).should_not be_nil
  end
  %w( jpg gif png ).each do |ext|
    it "should be able to tell if a file is an image" do
      t = Place.generate(:file => uploaded_file("#{RAILS_ROOT}/test/fixtures/places/test.#{ext}", "image/#{ext}", "test.#{ext}"))
      t.file_image?.should be_true
    end
  end
  %w( pdf doc ).each do |ext|
    it "should be able to tell if a file is an image" do
      t = Place.generate(:file => uploaded_file("#{RAILS_ROOT}/test/fixtures/places/test.#{ext}", "image/#{ext}", "test.#{ext}"))
      t.file_image?.should be_false
    end
  end
end
