require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectFlickrImage do
  before do
    @valid_attributes = Factory.build(:project_flickr_image).attributes
  end
  
  subject { ProjectFlickrImage.create!(@valid_attributes) }
  let(:project_flickr_image) { ProjectFlickrImage.create!(@valid_attributes) }
  
  it "should create a new instance given valid attributes" do
    ProjectFlickrImage.create!(@valid_attributes)
  end

  its(:exists?) { should be_true }

  describe "#owner" do
    let(:owner) { project_flickr_image.owner }
    specify { owner.should_not be_nil }
    specify { owner[:nsid].should_not be_nil }
    specify { owner[:username].should_not be_nil }
    specify { owner[:realname].should_not be_nil }
  end

  %w(square thumbnail small medium medium_640 large).each do |photo_size|
    describe "##{photo_size}" do
      let(:size) { project_flickr_image.send(photo_size.to_sym) }
      specify { size should_not be_nil }
      specify { size[:url].should_not be_nil }
      specify { size[:source].should_not be_nil }
      specify { size[:width].should_not be_nil }
      specify { size[:height].should_not be_nil }
    end
  end

  describe "with an invalid photo_id" do
    before do
      @valid_attributes[:photo_id] = 1
    end
    subject { ProjectFlickrImage.create!(@valid_attributes) }
    let(:project_flickr_image) { ProjectFlickrImage.create!(@valid_attributes) }

    its(:exists?) { should be_false }
    its(:owner) { should be_nil }

    %w(square thumbnail small medium medium_640 large).each do |photo_size|
      context "##{photo_size}" do
        let(:size) { subject.send(photo_size.to_sym) }
        specify { size.should be_nil }
      end
    end
  end
end