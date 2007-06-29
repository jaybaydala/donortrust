require File.dirname(__FILE__) + '/../test_helper'


context "MillenniumDevGoals" do
     fixtures :rss_feeds
  
  setup do
    @element = RssFeedElement.find(1)
  end
  
  specify "should have title" do
    @element.title = nil
    @element.should.not.validate
  end

end
