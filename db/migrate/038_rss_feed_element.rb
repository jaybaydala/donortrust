class RssFeedElement < ActiveRecord::Migration
  # for RSS Specifications visit - http://cyber.law.harvard.edu/rss/rss.html#sampleFiles
  
  def self.up 
    create_table :rss_feed_element, :force => true do |t|
      t.column :feed_id, :integer
      
      # all element fields are optional, however at least one must be present
      t.column :title, :string
      t.column :link, :string
      t.column :description, :text
      t.column :author, :string
      t.column :comments, :text
      t.column :enclosure, :string
      t.column :guid, :string
      t.column :pubDate, :datetime
      t.column :source, :string
      
    end
  end

  def self.down
    drop_table :rss_feed_element
  end
end
