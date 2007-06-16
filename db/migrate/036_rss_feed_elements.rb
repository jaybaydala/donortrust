class RssFeedElements < ActiveRecord::Migration
  # for RSS Specifications visit - http://cyber.law.harvard.edu/rss/rss.html#sampleFiles
  
  def self.up 
    create_table :rss_feed_elements, :force => true do |t|
      t.column :rss_feed_id, :integer, :null => false
      
      # all element fields are optional, however at least one must be present, also 
      # some of the elements are not present because they are kinda silly for our purposes
      t.column :title, :string
      t.column :link, :string
      t.column :description, :text
      t.column :author, :string
      t.column :comments, :text
      t.column :pubDate, :datetime
      t.column :source, :string
    end
  end

  def self.down
    drop_table :rss_feed_elements
  end
end
