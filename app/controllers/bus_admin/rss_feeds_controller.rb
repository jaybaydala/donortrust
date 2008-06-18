class BusAdmin::RssFeedsController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
  
  active_scaffold :rss_feeds do |config|
    config.list.columns = [:title, :link , :description, :pub_date]
  end

  def view_feed
    @feed = RssFeed.find(params[:id])
  end
  
  def get_local_actions(requested_action,permitted_action)
   case(requested_action)
      when("view_feed")
        return permitted_action == 'show'
      else
        return false
      end  
 end
end
