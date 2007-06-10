class RssFeed < ActiveRecord::Migration
  # creates RSSFeed table
  # for RSS Specifications visit - http://cyber.law.harvard.edu/rss/rss.html#sampleFiles
  
  def self.up
    create_table :rss_feed, :force => true do |t|
      # Required RSS Feed Fields
      t.column :title, :string, :not_null => true
      t.column :link , :string, :not_null => true
      t.column :description, :text
      
      # Optional Fields
      t.column :link, :string
      t.column :copyright, :string
      t.column :managingEditor, :string
      t.column :webMaster, :string
      t.column :pubDate, :datetime
      t.column :lastBuildDate, :datetime
      t.column :category, :string
      t.column :generator, :string
      t.column :docs, :string
      t.column :cloud, :string
      t.column :ttl, :integer
      t.column :image, :string
      t.column :rating, :string
      t.column :testInput, :string
      t.column :skipHours, :string
      t.column :skipDays, :string
    end
  end

  def self.down
    drop_table :rss_feed
  end
end
