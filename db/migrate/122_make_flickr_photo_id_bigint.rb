class MakeFlickrPhotoIdBigint < ActiveRecord::Migration
  def self.up
    change_column(:project_flickr_images, :photo_id, :bigint)
  end

  def self.down
    # same thing so as to not destroy data by putting values out of range of an int
    change_column(:project_flickr_images, :photo_id, :bigint)
  end
end
