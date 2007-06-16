class RssController < ApplicationController

  def show
    @feed = RssFeed.find(params[:id])
    render :layout => false
  end

end
