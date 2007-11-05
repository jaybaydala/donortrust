class Dt::ProjectsController < DtApplicationController
  include RssParser
  before_filter :project_id_to_session, :only=>[:facebook_login]
  before_filter :require_facebook_login, :only=>[:facebook_login]
  before_filter :store_location, :except=>[:facebook_login, :finish_facebook_login, :timeline]
  helper "dt/groups"

  def initialize
    @topnav = 'projects'
  end
  
  def index
    @projects = Project.find_public(:all, :conditions => { :featured => 1 })
    @projects = Project.find_public(:all, :limit => 3) if @projects.size == 0
    respond_to do |format|
      format.html
    end
  end
  
  # for sitemap.xml google sitemap functionality for projects
  #def sitemap
  #  @projects = Project.find_public(:all)
  #  respond_to do |format|
  #    format.xml {
  #      render :file => "#{RAILS_ROOT}/app/views/dt/projects/sitemap.rxml"
  #    }
  #  end
  #end

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
    @action_js = "http://simile.mit.edu/timeline/api/timeline-api.js"
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
    if @project.place and @project.place.facebook_group_id?
      @fb_group_available = true
      @facebook_group_link = "http://www.facebook.com/group.php?gid=#{@project.place.facebook_group_id}"
      if fbsession and fbsession.is_valid?:
        gid = @project.place.facebook_group_id
        @fbid = fbsession.users_getLoggedInUser()
        begin
          @fb_group = fbsession.groups_get(:gids=>gid)
          @fb_user = fbsession.users_getInfo(:uids=>@fbid, :fields=>["name"]).user_list[0]
          members_results = fbsession.groups_getMembers(:gid=>gid)
          # weird! api seems to have bug: cannot do member.uid from group results, have to jump thru hoops
          member_ids = members_results.search("//uid").map{|uidNode| uidNode.inner_html.to_i}
          @fb_members = fbsession.users_getInfo(:uids=>member_ids, :fields=>["name","pic_square", "pic", "pic_small"]).user_list
          @fb_member_pages, @members = fb_paginate_array(params[:page], @fb_members , 30)
          @fb_user_in_group = true if member_ids.find{ |id| Integer(@fbid.to_s)==id}
        rescue
          @fb_group_available = false
        end
      end
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
      # :action => 'connect', :id=>session[:project_id] 
      format.html { redirect_to dt_connect_project_path(project_id) }
    end
  end

  def timeline
    @project = Project.find(params[:id])
    @milestones = @project.milestones(:include => :tasks)
    @tasks = @project.tasks  #Task.find(:all, :joins=>['INNER Join milestones on tasks.milestone_id = milestones.id'], :conditions=> ['milestones.project_id = ?', @id])
    render :partial => 'timeline'
  end

  protected
  def project_id_to_session
    logger.debug '#####################'
    logger.debug 'FACEBOOK PROJECT_ID'
    logger.debug session[:project_id]
    session[:project_id] = params[:id]
    logger.debug session[:project_id]
  end

  def fb_paginate_array(page, array, items_per_page)
    @size = array.length
    page ||= 1
    page = page.to_i
    offset = (page - 1) * items_per_page
    pages = Paginator.new(self, array.length, items_per_page, page)
    array = array[offset..(offset + items_per_page - 1)]
    logger.debug 'FACEBOOK PAGINATION'
    logger.debug pages.inspect
    [pages, array]
  end
  
end
