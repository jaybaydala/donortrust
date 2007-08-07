class BusAdmin::ProjectYouTubeVideosController < ApplicationController
  before_filter :login_required, :check_authorization
  # GET /bus_admin_project_you_tube_videos
  # GET /bus_admin_project_you_tube_videos.xml
  def index
    if params[:id]
      @projects = Array.new
      @projects.push(Project.find_by_id(params[:id]))
    else
      @projects = Project.find(:all)    
    end
    @you_tube_videos = YouTubeVideo.find(:all)
    
    @project_pages, @projects = paginate_array(params[:project_page], @projects, 20)
    @you_tube_video_pages, @you_tube_videos = paginate_array(params[:video_page], @you_tube_videos, 20)

    [@projects, @project_pages, @you_tube_videos, @you_tube_video_pages]
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @project_you_tube_videos.to_xml }
    end
  end
  
  def show
    
  end
  
  def projects
    @projects = Project.find(:all)
    @project_pages, @projects = paginate_array(params[:page], @projects, 20)
    render :layout => false
  end
  
  def videos
    @you_tube_videos = YouTubeVideo.find(:all)
    @you_tube_video_pages, @you_tube_videos = paginate_array(params[:page], @you_tube_videos, 20)
    render :layout => false
  end
  
  def add 
    videoNameBuffer = params[:id]
    you_tube_video_id = videoNameBuffer[videoNameBuffer.rindex('_')+1,videoNameBuffer.size]
    if ProjectYouTubeVideo.find_by_project_id_and_you_tube_video_id(params[:project_id], you_tube_video_id) == nil

      ProjectYouTubeVideo.create :you_tube_video_id => you_tube_video_id, :project_id => params[:project_id]
      @msg = "You Tube Video successfully associated with project"
    else
      @msg = "The You Tube video is already associated with this project."
    end
    [@project = Project.find(params[:project_id]), @msg]
    render :layout => false
  end
  
  
  def remove
    stringBuffer = params[:id]
    chunks = stringBuffer.split('_')
    project_id = chunks[1]
    you_tube_video_id = chunks[5]
    @project_you_tube_video = ProjectYouTubeVideo.find_by_project_id_and_you_tube_video_id(project_id, you_tube_video_id)
    if @project_you_tube_video != nil
      @project_you_tube_video.destroy
     end
      @projects = Project.find_all()
    render(:partial => "project", :collection=>@projects, :locals=>{:project_id => project_id})
  end
  
  def search
    @projects = Array.new
    @searchstring = params[:project_search_keywords]
    @searchstring ||= params[:with][:project_search_keywords]
    if @searchstring != nil
      @searchphrases = @searchstring.split(' ')
      for searchPhrase in @searchphrases
        @results = Project.find(:all, :conditions => [ "LOWER(name) LIKE ?", '%'+searchPhrase.downcase+'%'])
        for result in @results
          if !@projects.include?(result)
            @projects.push(result)
          end
        end
      end
    end
    @size = @projects.length
    page = (params[:page] ||= 1).to_i
    items_per_page = 20
    offset = (page - 1) * items_per_page
    
    #@project_pages = Paginator.new(self, @projects.length, items_per_page, page)
    #@projects = @projects[offset..(offset + items_per_page - 1)]
    
    @project_pages, @projects = paginate_array(params[:page], @projects, 1)
    [@projects, @project_pages, @searchstring, @size]
    render :layout => false
  end

  
end

