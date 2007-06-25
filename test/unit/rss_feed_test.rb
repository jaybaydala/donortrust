require File.dirname(__FILE__) + '/../test_helper'
context "RSSFeed" do
  
  fixtures :rss_feed_elements
  
  setup do
    @rss_feed = RssFeed.find(1)
  end
  
  specify "should have title" do
    @rss_feed.title = nil
    @rss_feed.should.not.validate
  end
  
  specify "should have description" do
    @rss_feed.description = nil
    @rss_feed.should.not.validate
  end
  
  specify "should have link" do
    @rss_feed.link = nil
    @rss_feed.should.not.validate
  end
  
  specify "should have invalid image url" do
    @rss_feed.image_url = "This is not a valid image url"
    @rss_feed.should.not.validate
  end
  
  specify "should have valid image url" do
    @rss_feed.image_url = "http://www.blah.com/picture.png"
    @rss_feed.should.validate
  end
  
  specify "should have invalid link url" do
    @rss_feed.link = "not valid"
    @rss_feed.should.not.validate
  end
  
  specify "should have valid link url" do
    @rss_feed.link = "http://www.chsitmasfuture.org/"
    @rss_feed.should.validate
  end
  
  specify "should have invalid image link url" do
    @rss_feed.image_link = "not valid"
    @rss_feed.should.not.validate
  end
  
  specify "should have valid image link url" do
    @rss_feed.image_link = "http://www.imageLink.org/"
    @rss_feed.should.validate
  end
  
  specify "destroy should not orphan children" do
    @rss_feed.destroy
    elements = RssFeedElement.find_all_by_rss_feed_id(1)
    elements.size.should.equal 0
  end
end