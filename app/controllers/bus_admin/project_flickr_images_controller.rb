class BusAdmin::ProjectFlickrImagesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin' 

  active_scaffold :project_flickr_image do |config|
    config.columns =  [ :photo_id ]
  end
  
  
  
  # GET /bus_admin_project_flickr_images
  # GET /bus_admin_project_flickr_images.xml
  def index
    @flickr_images = ProjectFlickrImage.find(:all, :conditions => ["project_id = ", active_scaffold_session_storage[:constraints][:project_id]])
    @flickr_image_pages, @flickr_images = paginate_array(params[:page], @flickr_images, 20)
    
    if(params[:id])
      @project = Project.find(params[:id])
    end
    
    @project ||= Project.find(:first)
    
    [@project, @flickr_image_pages, @flickr_images]
  end

  # GET /bus_admin_project_flickr_images/1
  # GET /bus_admin_project_flickr_images/1.xml
  def show
    @project_flickr_image = ProjectFlickrImage.find(params[:id], :conditions => ["project_id = ?", active_scaffold_session_storage[:constraints][:project_id]])
    @photo = Flickr::Photo.new(@project_flickr_image.photo_id.to_s)
    
    respond_to do |format|
      format.html { render :action => "show", :layout => false }
      format.xml  { render :xml => @project_flickr_image.to_xml }
    end
  end
  
  def add
    @project = Project.find(params[:project_id])
    if @project.project_flickr_images.find_by_photo_id(params[:id])
      @msg = "That Photo has already been added to this project"
    else
      begin
        @project.project_flickr_images.create(:photo_id => params[:id])
        @msg = "Photo has been added to project"
      rescue
        @msg = "Photo could not be added to this project: " + $!.to_s
      end
    end
    
    [@project, @msg]
    render :partial => 'project'
  end
  
  def show_flickr
    @photo = Flickr::Photo.new(params[:id])
    @project_id = params[:project_id]
    @project_id ||= params[:with][:project_id]
    render :partial => 'show'
  end
    
  def show_db_flickr
    @photo = Flickr::Photo.new(params[:id])
    @project_id = params[:project_id]
    @project_id ||= params[:with][:project_id]
      
    render :partial => 'show', :locals => {:db => true}
  end
  def remove
   # chunks = params[:id].split('_')
   # project_id = chunks[0]
   # flickr_dt_id = chunks[1]
    begin
      ProjectFlickrImage.find_by_project_id_and_photo_id(params[:project_id],params[:id]).destroy
      @msg = "Photo has been removed from project"
    rescue
      @msg = "Photo could not be removed from project: " + $!.to_s
    end
    [@project = Project.find(params[:project_id]), @msg]
    render :partial => 'project'
  end

 def search
    flickr = Flickr.new
    begin
      @tags = params[:tags]
      @tags ||= params[:with][:tags]
      @project_id = params[:project_id]
      @project_id ||= params[:with][:project_id]
      
      @photos = flickr.photos(:tags => @tags, :per_page => '250')
      @size = @photos.size
      @flickr_photo_pages, @flickr_photos = paginate_array(params[:page], @photos, 20)

    rescue # hackish solution to shitty programming by the Author of the Flickr.rb library
      @flickr_photos = Array.new
      @photo_pages, @flickr_photos = paginate_array(params[:page], @photos, 20)

    end
    [@flickr_photos, @flickr_photo_pages, @tags, @size, @project_id]
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
