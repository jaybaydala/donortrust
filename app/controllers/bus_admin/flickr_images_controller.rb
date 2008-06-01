class BusAdmin::FlickrImagesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  # GET /bus_admin_flickr_images
  # GET /bus_admin_flickr_images.xml
  def index
    @flickr_images = FlickrImage.find(:all)
    @flickr_image_pages, @flickr_images = paginate_array(params[:page], @flickr_images, 20)
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @flickr_images.to_xml }
    end
  end
  
  def search
    flickr = Flickr.new
    begin
      @tags = params[:tags]
      @tags ||= params[:with][:tags]
      
      @photos = flickr.photos(:tags => @tags, :per_page => '250')
      @size = @photos.size
      @flickr_photo_pages, @flickr_photos = paginate_array(params[:page], @photos, 20)

    rescue # hackish solution to shitty programming by the Author of the Flickr.rb library
      @flickr_photos = Array.new
      @photo_pages, @flickr_photos = paginate_array(params[:page], @photos, 20)

    end
    [@flickr_photos, @flickr_photo_pages, @tags, @size]
    render :layout => false
  end
  
  def add 
    begin
      FlickrImage.create :photo_id => params[:id]
      @msg = "Flickr Photo Successfully Added"
    rescue
      @msg = "Flickr Photo Could Not Be Added: " + $!.to_s
    end
    @flickr_images = FlickrImage.find(:all)
    @flickr_image_pages, @flickr_images = paginate_array(params[:page], @flickr_images, 20)
    [@flickr_image_pages, @flickr_images, @msg]
    render :layout => false
  end

  def photos
    @flickr_images = FlickrImage.find(:all)
    @flickr_image_pages, @flickr_images = paginate_array(params[:page], @flickr_images, 20)
    render :action => 'add', :layout => false
  end
 
  def remove
    begin
      FlickrImage.find(params[:id]).destroy
      @msg = "Flickr Photo Successfully Destroyed"
    rescue
      @msg = "Flickr Photo Could Not Be Destroyed: " + $!.to_s
    end
    @flickr_images = FlickrImage.find(:all)
    @flickr_image_pages, @flickr_images = paginate_array(params[:page], @flickr_images, 20)
    [@flickr_image_pages, @flickr_images, @msg]
    render :action => 'add', :layout => false
  end

  def show_flickr
    @photo = Flickr::Photo.new(FlickrImage.find(params[:id]).photo_id.to_s)
    render :partial => 'show'
  end
    
  def show_db_flickr
    @photo = Flickr::Photo.new(params[:id])
    render :partial => 'show', :locals => {:db => true}
  end

def get_local_actions(requested_action,permitted_action)
   case(requested_action)
      when("search")
        return permitted_action == 'show'
      when("show_flickr")
        return permitted_action == 'show'
      when("show_db_flickr")
        return permitted_action == 'show'
      when("photos")
        return permitted_action == 'show'
      when("add")
        return permitted_action == 'create'
      when("remove")
        return permitted_action == 'delete'
      else
        return false
      end  
 end
end
