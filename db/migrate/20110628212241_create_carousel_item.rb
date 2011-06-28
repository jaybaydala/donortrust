class CreateCarouselItem < ActiveRecord::Migration
  def self.up
    create_table :carousel_items do |t|
      t.string :title_image_file_name
      t.string :title_image_content_type
      t.integer :title_image_file_size
      t.datetime :title_image_updated_at
      t.text :content
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.text :code
      t.integer :position
    end
  end

  def self.down
    drop_table :carousel_items
  end
end
