class FlickrImage < ActiveRecord::Base
  validates_presence_of :photo_id
  
  has_many :project_flickr_images, :dependent => :destroy
  has_many :projects, :through => :project_flickr_images
end
