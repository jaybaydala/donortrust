class ProjectFlickrImagesRel001 < ActiveRecord::Migration
  def self.up
    create_table :project_flickr_images do |t|
      t.column :project_id, :integer
      t.column :flickr_image_id, :integer
    end
  end

  def self.down
    drop_table :project_flickr_images
  end
end
