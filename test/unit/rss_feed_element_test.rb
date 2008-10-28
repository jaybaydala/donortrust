require File.dirname(__FILE__) + '/../test_helper'

context "RssFeedElement" do
  fixtures :rss_feeds, :rss_feed_elements
  
  setup do
    @element = RssFeedElement.find(1)
  end
  
  specify "should have title" do
    @element.title = nil
    @element.should.not.validate
  end
  
  specify "should have description" do
    @element.description = nil
    @element.should.not.validate
  end
  
  specify "should update parent pub date" do
    @element.title = "Doesn't Mater";
    @element.update
    @element.rss_feed.pub_date.to_s.should.equal DateTime.now.to_s
  end
end
