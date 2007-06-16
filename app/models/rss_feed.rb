class RssFeed < ActiveRecord::Base

  has_many :rss_feed_elements
  validates_presence_of :title, :link, :description
  
end
