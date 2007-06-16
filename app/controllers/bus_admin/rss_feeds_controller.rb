class BusAdmin::RssFeedsController < ApplicationController
  before_filter :login_required
  
  active_scaffold :rss_feeds do |config|
    config.list.columns = [:title, :link , :description, :pub_date]
  end

  def view_feed
    @feed = RssFeed.find(params[:id])
  end
end
