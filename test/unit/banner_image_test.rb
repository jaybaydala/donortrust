require File.dirname(__FILE__) + '/../test_helper'

context "Banner Image Tests " do
  fixtures :banner_images
 
  specify "should create a banner image" do
    BannerImage.should.differ(:count).by(1) {create_banner_image} 
  end
  
  specify "model_id should be numerical" do
    lambda {
      t = create_banner_image(:model_id => 'test')
      t.errors.on(:model_id).should.not.be.nil
    }.should.not.change(BannerImage, :count)
  end    
 
  def create_banner_image(options = {})
    BannerImage.create({ :model_id => 1, :controller => 'My Controller', :action => 'action', :file => uploaded_file(file_path("test.jpg"), "image/jpeg", "test") }.merge(options))
  end           
   
  def file_path(filename)
    File.expand_path("#{File.dirname(__FILE__)}/image/#{filename}")
  end
end  
