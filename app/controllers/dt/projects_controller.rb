class Dt::ProjectsController < DtApplicationController
  include RssParser
  before_filter :project_id_to_session, :only=>[:facebook_login]
  before_filter :require_facebook_login, :only=>[:facebook_login]

  def initialize
    @topnav = 'projects'
  end
  
  def index
    @projects = Project.find(:all, :conditions => { :featured => 1 })
    # TODO: Project should be order_by Rating once rating model is done
    @projects = Project.find(:all, :limit => 3) if @projects.size == 0
    respond_to do |format|
      format.html # index.rhtml
    end
  end

  def show
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @rss_feed = last_rss_entry(@project.rss_url) if @project && @project.rss_url
    #@rss_feed.clean! if @rss_feed # sanitize the html
    respond_to do |format|
      format.html
    end
  end

  def details
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end

  def community
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    
    @rss_feed = last_rss_entry(@project.community.rss_url) if @project && @project.community.rss_url?
    #@rss_feed.clean! if @rss_feed # sanitize the html
    @community = @project.community
  end
    
  def nation
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @nation = @project.nation
  end
  
  def organization
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @organization = @project.partner if @project.partner_id?
  end
    
  def connect
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end

    #facebook stuff
    #gid = @project.place.facebook_group_id
    if @project.place and @project.place.facebook_group_id
      @fb_group_available = true
      @facebook_group_link = "http://www.facebook.com/group.php?gid=#{@project.place.facebook_group_id}"
    end
    if fbsession and fbsession.is_valid?:
      #gid = 3362029547
      gid = @project.place.facebook_group_id
      @fbid = fbsession.users_getLoggedInUser()
      @fb_group = fbsession.groups_get(:gids=>gid)
      @fb_user = fbsession.users_getInfo(:uids=>@fbid, :fields=>["name"]).user_list[0]
      members_results = fbsession.groups_getMembers(:gid=>gid)
      # wierd! api seems to have bug: cannot do member.uid from group results, have to jump thru hoops
      member_ids = members_results.search("//uid").map{|uidNode| uidNode.inner_html.to_i}
      @fb_members = fbsession.users_getInfo(:uids=>member_ids, :fields=>["name","pic_square", "pic", "pic_small"]).user_list
      @fb_member_pages, @members = fb_paginate_array(params[:page], @fb_members , 30)
      @fb_user_in_group = true if member_ids.find{ |id| Integer(@fbid.to_s)==id}
    end
  end

  def facebook_login
    # placeholder for the before_filters above: project_id_to_session, facebook_login
    # is there a more elegant way to do this? 
    # project_id_to_session: stores the project id in the (surprise) session, 
    # require_facebook_login is a rfacebook thing that bounces the user to facebook, gets a session id, and stores it in the rails session, makes the fbsession object available to controllers
  end
  def finish_facebook_login
    project_id = session[:project_id]
    session[:project_id] = nil
    respond_to do |format|
      # TODO: translate to the hash format
      # :action => 'community', :id=>session[:project_id] 
      format.html { redirect_to "/dt/projects/#{project_id};community" }
    end
  end

  def project_id_to_session
    puts session[:project_id]
    session[:project_id] = params[:id]
    puts session[:project_id]
  end

  def fb_paginate_array(page, array, items_per_page)
    @size = array.length
    page ||= 1
    page = page.to_i
    offset = (page - 1) * items_per_page
    pages = Paginator.new(self, array.length, items_per_page, page)
    array = array[offset..(offset + items_per_page - 1)]
    [pages, array]
  end

end
