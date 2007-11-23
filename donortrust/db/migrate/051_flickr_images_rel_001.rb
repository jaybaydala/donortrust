class FlickrImagesRel001 < ActiveRecord::Migration
  def self.up
    create_table :flickr_images do |t|
      t.column :photo_id, :integer
      t.column :tags, :string
    end
  end

  def self.down
    drop_table :flickr_images
  end
end
