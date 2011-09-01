class AddLinkToCarouselItems < ActiveRecord::Migration
  def self.up
    add_column :carousel_items, :link, :string
    add_column :carousel_items, :link_text, :string
  end

  def self.down
    remove_column :carousel_items, :link_text
    remove_column :carousel_items, :link
  end
end
