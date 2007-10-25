class ProjectFlickrChangeFlickrId < ActiveRecord::Migration
  def self.up
    rename_column(:project_flickr_images, :flickr_image_id, :photo_id)
  end

  def self.down
    rename_column(:project_flickr_images, :photo_id, :flickr_image_id)
  end
end

