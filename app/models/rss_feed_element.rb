class RssFeedElement < ActiveRecord::Base
  belongs_to :rss_feed
  validates_presence_of :title, :description
  
  def after_create
    puts "what what"
    self.rss_feed.pub_date = DateTime.now
  end
  
  def after_update
    puts "what what"
    self.rss_feed.pub_date = DateTime.now
  end
  
end
