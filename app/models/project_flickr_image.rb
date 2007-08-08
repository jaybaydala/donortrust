class ProjectFlickrImage < ActiveRecord::Base
  belongs_to :project
  belongs_to :flickr_image
end
