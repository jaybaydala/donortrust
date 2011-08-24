class BusAdmin::CarouselItemsController < ApplicationController
  layout 'admin'
  
  active_scaffold :carousel_item do |config|
    config.list.sorting = { :position => :asc, :id => :asc }
    config.create.multipart = true
    config.update.multipart = true
    config.columns = [ :title, :title_image, :content, :link, :link_text, :image, :code, :position ]
    config.list.columns = [ :title, :position ]
    list.columns.exclude [ :title_image, :content, :image, :code ]
  end
end
