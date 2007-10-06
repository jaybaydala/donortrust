class BusAdmin::ProjectFlickrImagesController < ApplicationController
  before_filter :login_required, :check_authorization
  # GET /bus_admin_project_flickr_images
  # GET /bus_admin_project_flickr_images.xml
  def index
    @flickr_images = FlickrImage.find(:all)
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
    @project_flickr_images = ProjectFlickrImage.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @project_flickr_images.to_xml }
    end
  end
  
  def add
    if(ProjectFlickrImage.find_by_project_id_and_flickr_image_id(params[:project_id],params[:id]) == nil)
      begin
        ProjectFlickrImage.create :project_id => params[:project_id], :flickr_image_id => params[:id]
        @msg = "Photo has been added to project"
      rescue
        @msg = "Photo could not be added to this projectL: " + $!.to_s
      end
    else
      @msg = "That Photo has already been added to this project"
    end
    
    [@project = Project.find(params[:project_id]), @msg]
    render :partial => 'project'
  end

  def remove
    chunks = params[:id].split('_')
    project_id = chunks[0]
    flickr_dt_id = chunks[1]
    begin
      ProjectFlickrImage.find_by_project_id_and_flickr_image_id(project_id,flickr_dt_id).destroy
      @msg = "Photo has been removed from project"
    rescue
      @msg = "Photo could not be removed from project: " + $!.to_s
    end
    [@project = Project.find(project_id), @msg]
    render :partial => 'project'
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
