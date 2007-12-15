class RssFeeds < ActiveRecord::Migration
  def self.up
    create_table :rss_feeds, :force => true do |t|
      # for complete RSS Specification please se http://cyber.law.harvard.edu/rss/rss.html
      # I've ommited a few of the elements as they seem pointless in our context.
      
      # required fields
      t.column :title, :string, :null => false
      t.column :link, :string, :null => false
      t.column :description, :text, :null => false
     
      t.column :language, :string
      t.column :copyright, :string
      t.column :managing_editor, :string # this will likely be the PM
      t.column :pub_date, :datetime
      
      t.column :image_url, :string
      t.column :image_title, :string
      t.column :image_link, :string
    end
  end

  def self.down
    drop_table :rss_feeds
  end
end
