class BusAdmin::PlaceFlickrImagesController < ApplicationController
#  before_filter :login_required, :check_authorization
  # GET /bus_admin_project_flickr_images
  # GET /bus_admin_project_flickr_images.xml
  def index
    @flickr_images = PlaceFlickrImage.find(:all, :conditions => "place_id = " + params[:id].to_s)
    @flickr_image_pages, @flickr_images = paginate_array(params[:page], @flickr_images, 20)
    
    if(params[:id])
      @place = Place.find(params[:id])
    end
    
    @place ||= Place.find(:first)
    
    [@place, @flickr_image_pages, @flickr_images]
  end

  # GET /bus_admin_project_flickr_images/1
  # GET /bus_admin_project_flickr_images/1.xml
  def show
    @place_flickr_images = PlaceFlickrImage.find(:all, :conditions => "place_id = " + params[:id].to_s)

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @place_flickr_images.to_xml }
    end
  end
  
  def add
    if(PlaceFlickrImage.find_by_place_id_and_photo_id(params[:place_id],params[:id]) == nil)
      begin
        PlaceFlickrImage.create :place_id => params[:place_id], :photo_id => params[:id]
        @msg = "Photo has been added to place"
      rescue
        @msg = "Photo could not be added to this place: " + $!.to_s
      end
    else
      @msg = "That Photo has already been added to this place"
    end
    
    [@place = Place.find(params[:place_id]), @msg]
    render :partial => 'place'
  end
  
 def show_flickr
    @photo = Flickr::Photo.new(params[:id])
     @place_id = params[:place_id]
      @place_id ||= params[:with][:place_id]
      
    render :partial => 'show'
  end
    
  def show_db_flickr
    @photo = Flickr::Photo.new(params[:id])
    @place_id = params[:place_id]
      @place_id ||= params[:with][:place_id]
      
    render :partial => 'show', :locals => {:db => true}
  end
  def remove
   # chunks = params[:id].split('_')
   # project_id = chunks[0]
   # flickr_dt_id = chunks[1]
    begin
      PlaceFlickrImage.find_by_place_id_and_photo_id(params[:place_id],params[:id]).destroy
      @msg = "Photo has been removed from place"
    rescue
      @msg = "Photo could not be removed from place " + $!.to_s
    end
    [@place = Place.find(params[:place_id]), @msg]
    render :partial => 'place'
  end

 def search
    flickr = Flickr.new
    begin
      @tags = params[:tags]
      @tags ||= params[:with][:tags]
      @place_id = params[:place_id]
      @place_id ||= params[:with][:place_id]
      
      @photos = flickr.photos(:tags => @tags, :per_page => '250')
      @size = @photos.size
      @flickr_photo_pages, @flickr_photos = paginate_array(params[:page], @photos, 20)

    rescue # hackish solution to shitty programming by the Author of the Flickr.rb library
      @flickr_photos = Array.new
      @photo_pages, @flickr_photos = paginate_array(params[:page], @photos, 20)

    end
    [@flickr_photos, @flickr_photo_pages, @tags, @size, @place_id]
    render :layout => false
  end
  

  def get_local_actions(requested_action,permitted_action)
   case(requested_action)
      when("add")
        return permitted_action == 'create'
      when("remove")
        return permitted_action == 'delete'
      else
        return false
      end  
   end
end
