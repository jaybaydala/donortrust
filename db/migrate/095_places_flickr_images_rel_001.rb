class PlacesFlickrImagesRel001 < ActiveRecord::Migration
  def self.up
    create_table :place_flickr_images do |t|
      t.column :place_id, :integer
      t.column :photo_id, :integer
      t.column :created_at,           :datetime
      t.column :updated_at,           :datetime
    end
  end

  def self.down
    drop_table :place_flickr_images
  end
end
