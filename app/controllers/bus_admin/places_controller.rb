class BusAdmin::PlacesController < ApplicationController
 #before_filter :login_required, :check_authorization
  
  active_scaffold :places do |config|
    config.columns =[ :name, :place_type, :file,:blog_url, :rss_url , :facebook_group_id, :description ]
    list.columns.exclude [ :blog_url, :rss_url, :description, :facebook_group_id ]
    config.columns[ :place_type ].form_ui = :select
    
   config.columns[:children].association.reverse = :parent

    config.nested.add_link("Next", [:children]) 
    config.nested.add_link("Quick Fact", [:quick_fact_places]) 
    config.nested.add_link("Sectors", [:place_sectors]) 
    config.columns[ :file ].label = "Image File"
    config.columns[ :facebook_group_id ].label = "Facebook Group Id"
    config.create.multipart = true
    config.update.multipart = true
    
    config.action_links.add 'index', :label => '<img src="/images/bus_admin/icons/you_tube.png" border=0>', :page => true, :type=> :record, :parameters =>{:controller=>"bus_admin/place_you_tube_videos"}
    config.action_links.add 'index', :label => '<img src="/images/bus_admin/icons/flickr.png" border=0>', :page => true, :type=> :record, :parameters =>{:controller=>"bus_admin/place_flickr_images"}
  end
  
  def list
    @places= Place.find_all_by_parent_id(nil)
  end
end 
  
