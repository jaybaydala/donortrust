class MakeFlickrPhotoIdBigint < ActiveRecord::Migration
  def self.up
    change_column(:project_flickr_images, :photo_id, :bigint)
  end

  def self.down
    change_column(:project_flickr_images, :photo_id, :int)
  end
end
