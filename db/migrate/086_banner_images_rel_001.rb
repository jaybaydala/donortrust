class BannerImagesRel001 < ActiveRecord::Migration
  def self.up
    create_table :banner_images, :force => true do |t|
      t.column :model_id,       :int
      t.column :controller, :string
      t.column :action, :string
      t.column :file, :text
      t.column :deleted_at, :datetime
    end
  end

  def self.down
    drop_table :banner_images
  end
end



