class BusAdmin::ProjectYouTubeVideosController < ApplicationController
 # before_filter :login_required, :check_authorization
  # GET /bus_admin_project_you_tube_videos
  # GET /bus_admin_project_you_tube_videos.xml
  
  def index   
    @project_id = params[:id]
    if params[:id]
      @project = Project.find_by_id(params[:id])
    else
      @project = Project.find(:first)  
    end
    @you_tube_videos = ProjectYouTubeVideo.find(:all, :conditions => "project_id = " + params[:id].to_s)
    
    @you_tube_video_pages, @you_tube_videos = paginate_array(params[:video_page], @you_tube_videos, 20)

    [@project, @you_tube_videos, @you_tube_video_pages, @project_id]
    
    render :action => :index
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @you_tube_videos.to_xml }
    end
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
    @project_id = params[:project_id]
    if ProjectYouTubeVideo.find_by_project_id_and_you_tube_id(params[:project_id], params[:id]) == nil
      ProjectYouTubeVideo.create :you_tube_id => params[:id], :project_id => params[:project_id]
      @msg = "You Tube Video successfully associated with project"
    else
      @msg = "The You Tube video is already associated with this project."
    end
    [@project = Project.find(params[:project_id]), @msg, @project_id]
    render :layout => false
  end
  
  
  def remove
   @project_id = params[:project_id]
    @project_you_tube_video = ProjectYouTubeVideo.find_by_project_id_and_you_tube_id(params[:project_id], params[:id])
    if @project_you_tube_video != nil
      @project_you_tube_video.destroy
     end
      @projects = Project.find_all()
    render(:partial => "project", :collection=>@projects, :locals=>{:project_id => params[:project_id]})
  end
  
  def search
    @projects = Array.new
    @project_id = params[:project_id]
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
    [@projects, @project_pages, @searchstring, @size, @project_id]
    render :layout => false
  end

  
  

  ## These are YouTube Search methods for getting stuff from the YouTube Database
  def search_by_tag
    @project_id = params[:project_id]
    @you_tube_videos = RubyTube.new().list_by_tag(params[:tags],1,20)
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}   
  end
  
  
  def search_by_user
    @project_id = params[:project_id]
    params[:user] = params[:user].gsub(' ','') # cleaning user name of spaces
    @you_tube_videos = RubyTube.new().list_by_user(params[:user],1,20)
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"} 
  end

  def search_by_category_and_tag
    @project_id = params[:project_id]
    @you_tube_videos = RubyTube.new().list_by_category_and_tag(params[:tags],params[:category],1,20)
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}
  end
  
  def list_by_featured
    @project_id = params[:project_id]
    @you_tube_videos = RubyTube.new().list_featured
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}
  end
  
  def list_by_popular
    @project_id = params[:project_id]
    @you_tube_videos = RubyTube.new().list_popular(params[:popular])
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}
  end
  
  def show_video
    @project_id = params[:project_id]
    you_tube_db_video = RubyTube.new().get_video(params[:id])
    render :partial => 'show_video', :locals => {:you_tube_db_video => you_tube_db_video}
  end
  
  def get_local_actions(requested_action,permitted_action)
   case(requested_action)
      when('list_by_popular')
        return permitted_action == 'show'
      
      when('show_video')
        return permitted_action == 'show'
      when("add")
        return permitted_action == 'create'
      when("remove")
        return permitted_action == 'destroy'
      else
        return false
      end  
 end
  
end
