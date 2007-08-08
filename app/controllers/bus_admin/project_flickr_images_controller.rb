class BusAdmin::ProjectFlickrImagesController < ApplicationController
  # GET /bus_admin_project_flickr_images
  # GET /bus_admin_project_flickr_images.xml
  def index
    @flickr_images = FlickrImage.find(:all)
    @flickr_image_pages, @flickr_images = paginate_array(params[:page], @flickr_images, 20)
    
    if params[:id]
      @projects = Array.new
      @projects.push(Project.find_by_id(params[:id]))
    else
      @projects = Project.find(:all)    
    end
    
    @project_pages, @projects = paginate_array(params[:project_page], @projects, 20)
    [@projects, @project_pages, @flickr_image_pages, @flickr_images]
  end

  # GET /bus_admin_project_flickr_images/1
  # GET /bus_admin_project_flickr_images/1.xml
  def show
    @project_flickr_images = ProjectFlickrImage.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @project_flickr_images.to_xml }
    end
  end
  
  def add
    flickr_dt_id = params[:id][(params[:id].rindex('_') + 1 ),params[:id].size]
    if(ProjectFlickrImage.find_by_project_id_and_flickr_image_id(params[:project_id],flickr_dt_id) == nil)
      ProjectFlickrImage.create :project_id => params[:project_id], :flickr_image_id => flickr_dt_id
      @msg = "Photo has been added to project"
    else
      @msg = "That Photo has already been added to this project"
    end
    
    [@project = Project.find(params[:project_id]), @msg]
    render :layout => false
  end

  def remove
    
  end

end
