class BusAdmin::FlickrImagesController < ApplicationController
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
      @photo_pages, @photos = paginate_array(params[:page], @photos, 20)

    rescue # hackish solution to shitty programming by the Author of the Flickr.rb library
      @photos = Array.new
      @photo_pages, @photos = paginate_array(params[:page], @photos, 20)
    end
    [@photos, @photo_pages, @tags, @size]
    render :layout => false
  end
  
  def add 
    id = params[:id]
    if(id.to_s.include? "flickr_db_image_")
      chunks = id.split('_')
      id = chunks[chunks.size-1]
      FlickrImage.create :photo_id => id
      @msg = "Image Sucessfully Added."
    else
      @msg = "Couldn't Add that to the database"
    end
    @flickr_images = FlickrImage.find(:all)
    [@flickr_image_pages, @flickr_images = paginate_array(params[:page], @flickr_images, 20), @msg]
    render :layout => false
  end

  def photos
    @flickr_images = FlickrImage.find(:all)
    @flickr_image_pages, @flickr_images = paginate_array(params[:page], @flickr_images, 20)
    render :action => 'add', :layout => false
  end
 
  def remove
    id = params[:id]
    if(id.to_s.include? "flickr_dt_image_")
      chunks = id.split('_')
      id = chunks[chunks.size-1]
      @flickr_image = FlickrImage.find(id)
      @flickr_image.destroy
      @msg = "Image Sucessfully Deleted."
    else
      @msg = "Couldn't Destory that to the database"
    end
    [@flickr_images = FlickrImage.find(:all), @msg]
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
end
