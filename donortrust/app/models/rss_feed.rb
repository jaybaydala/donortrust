class RssFeed < ActiveRecord::Base

  has_many :rss_feed_elements, :dependent => :destroy
  validates_presence_of :title, :link, :description
  validates_format_of :link, 
      :with => %r{.+://.+..+},
      :message => "must be a valid url"

   validates_format_of :image_link, 
      :with => %r{.+://.+..+},
      :message => "must be a valid url"
  
  validates_format_of :image_url, 
      :with => %r{^http:.+\.(gif|jpg|png)$}i, 
      :message => "must be a URL for a GIF, JPG, or PNG image" 

  
end
