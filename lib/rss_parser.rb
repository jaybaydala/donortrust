require 'open-uri'
require 'feed-normalizer'
module RssParser
  protected
  def last_rss_entry(uri)
    feed = FeedNormalizer::FeedNormalizer.parse open(uri.strip)
  end
end
