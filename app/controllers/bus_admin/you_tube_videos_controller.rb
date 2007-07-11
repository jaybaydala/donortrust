require 'net/http'
require 'uri'

class BusAdmin::YouTubeVideosController < ApplicationController

  # GET /bus_admin_you_tube_videos
  # GET /bus_admin_you_tube_videos.xml
  def index
    @you_tube_videos = BusAdmin::YouTubeVideo.find(:all)
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @bus_admin_you_tube_videos.to_xml }
    end
  end

  # GET /bus_admin_you_tube_videos/1
  # GET /bus_admin_you_tube_videos/1.xml
  def show
    @you_tube_video = BusAdmin::YouTubeVideo.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @you_tube_video.to_xml }
    end
  end

  def search
#    @you_tube_videos = BusAdmin::YouTubeVideo.find(:all, :conditions => ["match(comments) against (?)",])
#    respond_to do |format|
#      format.html # index.rhtml
#      format.xml  { render :xml => @bus_admin_you_tube_videos.to_xml }
#    end
  end

  # GET /bus_admin_you_tube_videos/new
  def new
    @you_tube_video = BusAdmin::YouTubeVideo.new
  end

  def preview
    if(params[:you_tube_videos_you_tube_reference])
      result = getVideoHash(params[:you_tube_videos_you_tube_reference])
    else
      result = getVideoHash(params[:v])
    end
    result
    render :layout => false
  end

  def getVideoHash(url)
    response = Net::HTTP.get_response(URI.parse('http://www.youtube.com/api2_rest?method=youtube.videos.get_details&dev_id=BayCH1FukEw&video_id=' + url))
    @video_hash = Hash.create_from_xml response.body[0,response.body.size]
  end

  # GET /bus_admin_you_tube_videos/1;edit
  def edit
    @you_tube_video = BusAdmin::YouTubeVideo.find(params[:id])
  end

  # POST /bus_admin_you_tube_videos
  # POST /bus_admin_you_tube_videos.xml
  def create
    @you_tube_video = YouTubeVideo.new(params[:you_tube_videos])
    
    url = params[:you_tube_videos][:you_tube_reference]
    chunks = url.split("v=")
    ref = chunks[1].split("&")
    
    @you_tube_video.keywords = getVideoHash(ref[0])["ut_response"]["video_details"]["tags"]
    @you_tube_video.you_tube_reference = ref[0]

    respond_to do |format|
      if @you_tube_video.save
        flash[:notice] = 'You Tube Video was successfully created.'
        format.html { redirect_to you_tube_video_url(@you_tube_video) }
        format.xml  { head :created, :location => you_tube_video_url(@you_tube_video) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @you_tube_video.errors.to_xml }
      end
    end
  end

  # PUT /bus_admin_you_tube_videos/1
  # PUT /bus_admin_you_tube_videos/1.xml
  def update
    @you_tube_video = BusAdmin::YouTubeVideo.find(params[:id])
    respond_to do |format|
      if @you_tube_video.update_attributes(params[:you_tube_video])
        flash[:notice] = 'BusAdmin::YouTubeVideo was successfully updated.'
        format.html { redirect_to you_tube_video_url(@you_tube_video) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @you_tube_video.errors.to_xml }
      end
    end
  end

  # DELETE /bus_admin_you_tube_videos/1
  # DELETE /bus_admin_you_tube_videos/1.xml
  def destroy
    @you_tube_video = BusAdmin::YouTubeVideo.find(params[:id])
    @you_tube_video.destroy
    respond_to do |format|
      format.html { redirect_to you_tube_videos_url }
      format.xml  { head :ok }
    end
  end
end
