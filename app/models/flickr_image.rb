class FlickrImage < ActiveRecord::Base
  validates_presence_of :photo_id
end
