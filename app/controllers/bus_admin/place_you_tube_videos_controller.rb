class BusAdmin::PlaceYouTubeVideosController < ApplicationController
 # before_filter :login_required, :check_authorization
  # GET /bus_admin_project_you_tube_videos
  # GET /bus_admin_project_you_tube_videos.xml
  def index
    
     @place_id = params[:id]
    if params[:id]
      @place = Place.find_by_id(params[:id])
    else
      @place = Place.find(:first)  
    end
    @you_tube_videos = PlaceYouTubeVideo.find(:all, :conditions => "place_id = " + params[:id].to_s)
    
    @you_tube_video_pages, @you_tube_videos = paginate_array(params[:video_page], @you_tube_videos, 20)

    [@place, @you_tube_videos, @you_tube_video_pages, @place_id]
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @you_tube_videos.to_xml }
    end
 end 

  
  def places
    @places = Place.find(:all)
    @place_pages, @places = paginate_array(params[:page], @places, 20)
    render :layout => false
  end
  
  
  def add
    @place_id = params[:place_id]
    if PlaceYouTubeVideo.find_by_place_id_and_you_tube_id(params[:place_id], params[:id]) == nil
      PlaceYouTubeVideo.create :you_tube_id => params[:id], :place_id => params[:place_id]
      @msg = "You Tube Video successfully associated with place"
    else
      @msg = "The You Tube video is already associated with this place."
    end
    [@place = Place.find(params[:place_id]), @msg, @place_id]
    render :layout => false
  end
  
  
  def remove
   @place_id = params[:place_id]
    @place_you_tube_video = PlaceYouTubeVideo.find_by_place_id_and_you_tube_id(params[:place_id], params[:id])
    if @place_you_tube_video != nil
      @place_you_tube_video.destroy
     end
      @places = Place.find_all()
    render(:partial => "place", :collection=>@places, :locals=>{:place_id => params[:place_id]})
  end
  
  def search
    @places = Array.new
    @searchstring = params[:place_search_keywords]
    @searchstring ||= params[:with][:place_search_keywords]
    if @searchstring != nil
      @searchphrases = @searchstring.split(' ')
      for searchPhrase in @searchphrases
        @results = Place.find(:all, :conditions => [ "LOWER(name) LIKE ?", '%'+searchPhrase.downcase+'%'])
        for result in @results
          if @places.include?(result)
            @places.push(result)
          end
        end
      end
    end
    @size = @places.length
    page = (params[:page] ||= 1).to_i
    items_per_page = 20
    offset = (page - 1) * items_per_page
    
    #@project_pages = Paginator.new(self, @projects.length, items_per_page, page)
    #@projects = @projects[offset..(offset + items_per_page - 1)]
    
    @place_pages, @places = paginate_array(params[:page], @places, 1)
    [@places, @place_pages, @searchstring, @size]
    render :layout => false
  end

  
  

  ## These are YouTube Search methods for getting stuff from the YouTube Database
  def search_by_tag
    @place_id = params[:place_id]
    @you_tube_videos = RubyTube.new().list_by_tag(params[:tags],1,20)
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}   
  end
  
  
  def search_by_user
     @place_id = params[:place_id]
    params[:user] = params[:user].gsub(' ','') # cleaning user name of spaces
    @you_tube_videos = RubyTube.new().list_by_user(params[:user],1,20)
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"} 
  end

  def search_by_category_and_tag
   @place_id = params[:place_id]
   @you_tube_videos = RubyTube.new().list_by_category_and_tag(params[:tags],params[:category],1,20)
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}
  end
  
  def list_by_featured
     @place_id = params[:place_id]
    @you_tube_videos = RubyTube.new().list_featured
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}
  end
  
  def list_by_popular
     @place_id = params[:place_id]
    @you_tube_videos = RubyTube.new().list_popular(params[:popular])
    render :partial => 'you_tube_video', :collection => @you_tube_videos, :locals => {:class_name => "you_tube_video"}
  end
  
  def show_video
     @place_id = params[:place_id]
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
