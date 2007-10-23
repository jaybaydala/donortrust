require 'open-uri'
require 'feed-normalizer'
module RssParser
  protected
  def last_rss_entry(uri)
    uri.strip! unless uri.nil?
    feed = FeedNormalizer::FeedNormalizer.parse open(uri) if uri && !uri.empty?
  end
end
