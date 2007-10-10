require 'net/http'
require 'uri'

class BusAdmin::YouTubeVideosController < ApplicationController
 before_filter :login_required, :check_authorization
  def index
    @you_tube_videos = YouTubeVideo.find(:all)
    @you_tube_video_pages, @you_tube_videos = paginate_array(params[:page],@you_tube_videos , 20)
  end

  def search
    @you_tube_videos = Array.new
    @searchstring = params[:search_keywords]
    @searchstring ||= params[:with][:search_keywords]
    if @searchstring != nil
      @searchphrases = @searchstring.split(' ')
      for searchPhrase in @searchphrases
        @results = YouTubeVideo.find(:all, :conditions => [ "LOWER(keywords) LIKE ?", '%'+searchPhrase.downcase+'%'])
        for result in @results
          if !@you_tube_videos.include?(result)
            @you_tube_videos.push(result)
          end
        end
      end
    end
    @size = @you_tube_videos.length
    page = (params[:page] ||= 1).to_i
    items_per_page = 20
    offset = (page - 1) * items_per_page
    
    @you_tube_video_pages = Paginator.new(self, @you_tube_videos.length, items_per_page, page)
    @you_tube_videos = @you_tube_videos[offset..(offset + items_per_page - 1)]
    
    [@you_tube_videos, @you_tube_video_pages, @searchstring, @size]
    render :layout => false
  end
  
  

  # GET /bus_admin_you_tube_videos/new
  def new
    @you_tube_video = YouTubeVideo.new
  end

  def remove
    YouTubeVideo.find(params[:id]).destroy
    @you_tube_videos = YouTubeVideo.find(:all)
    @you_tube_video_pages, @you_tube_videos = paginate_array(params[:page],@you_tube_videos , 20)
    render :action => 'list_videos', :layout => false
  end
  
  def list_videos
    @you_tube_videos = YouTubeVideo.find(:all)
    @you_tube_video_pages, @you_tube_videos = paginate_array(params[:page],@you_tube_videos , 20)
    render :layout => false
  end
  
  def edit_video
    puts params.inspect
    @you_tube_video = YouTubeVideo.find(params[:id])
    render :partial => 'edit'
  end

  # POST /bus_admin_you_tube_videos
  # POST /bus_admin_you_tube_videos.xml
  def add
    video = RubyTube.new().get_video(params[:id])
    @you_tube_video = YouTubeVideo.new
    @you_tube_video.keywords = video.tags
    @you_tube_video.you_tube_reference = params[:id]
    if @you_tube_video.save
      flash[:notice] = 'You Tube Video was successfully created.'
    else
      flash[:notice] = 'You Tube Video was not created.'
    end
    
    @you_tube_videos = YouTubeVideo.find(:all)
    @you_tube_video_pages, @you_tube_videos = paginate_array(params[:page],@you_tube_videos , 20)
    render :action => 'list_videos', :layout => false
  end

  # PUT /bus_admin_you_tube_videos/1
  # PUT /bus_admin_you_tube_videos/1.xml
  def update
    @you_tube_video = YouTubeVideo.find(params[:id])
    respond_to do |format|
      if @you_tube_video.update_attributes(params[:you_tube_video])
        flash[:notice] = 'YouTubeVideo was successfully added.'
        format.html { redirect_to you_tube_videos_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @you_tube_video.errors.to_xml }
      end
    end
  end

  ## These are YouTube Search methods for getting stuff from the YouTube Database
  def search_by_tag
    @you_tube_videos = RubyTube.new().list_by_tag(params[:tags],1,20)
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}   
  end
  
  
  def search_by_user
    params[:user] = params[:user].gsub(' ','') # cleaning user name of spaces
    @you_tube_videos = RubyTube.new().list_by_user(params[:user],1,20)
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"} 
  end

  def search_by_category_and_tag
    @you_tube_videos = RubyTube.new().list_by_category_and_tag(params[:tags],params[:category],1,20)
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}
  end
  
  def list_by_featured
    @you_tube_videos = RubyTube.new().list_featured
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}
  end
  
  def list_by_popular
    @you_tube_videos = RubyTube.new().list_popular(params[:popular])
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}
  end
  
  def show_video
    you_tube_db_video = RubyTube.new().get_video(params[:id])
    render :partial => 'show_video', :locals => {:you_tube_db_video => you_tube_db_video}
  end
  
  def get_local_actions(requested_action,permitted_action)
   case(requested_action)
      when('list_by_popular')
        return permitted_action == 'show'
      when('edit_video')
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
