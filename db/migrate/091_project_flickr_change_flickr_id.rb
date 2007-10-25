class ProjectFlickrChangeFlickrId < ActiveRecord::Migration
  def self.up
    rename_column(:project_flickr_images, :flickr_image_id, :flickr_id)
  end

  def self.down
    rename_column(:project_flickr_images, :flickr_id, :flickr_image_id)
  end
end

