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
    @page_title = 'Featured Projects'
    @projects = Project.featured_projects
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
    @page_title = @project.name
    @rss_feed = last_rss_entry(@project.rss_url) if @project && @project.rss_url
    @flickr_images = @project.project_flickr_images.paginate({:page => params[:flickr_page], :per_page => 12})
    @youtube_videos = @project.project_you_tube_videos.paginate({:page => params[:youtube_page], :per_page => 6})
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
    @page_title = "Project Details | #{@project.name}"
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
    @community = @project.community
    @page_title = "#{@community.name} | #{@project.name}"
    
    @mdgs = MillenniumGoal.find(:all)
    @rss_feed = last_rss_entry(@project.community.rss_url) if @project && @project.community.rss_url?
    #@rss_feed.clean! if @rss_feed # sanitize the html
    respond_to do |format|
      format.html
    end
  end
    
  def nation
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @nation = @project.nation
    @page_title = "#{@nation.name} | #{@project.name}"
    @mdgs = MillenniumGoal.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def organization
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @organization = @project.partner if @project.partner_id?
    @page_title = "#{@organization.name} | #{@project.name}"
    respond_to do |format|
      format.html
    end
  end
    
  def connect
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @public_groups = @project.public_groups.paginate({:page => params[:page], :per_page => 10})
    @page_title = "Connect | #{@project.name}"

    integrate_facebook
    respond_to do |format|
      format.html
    end
  end

  def cause
    begin
      @project = Project.find_public(params[:id])
      @cause = Cause.find(params[:cause_id]) if params[:cause_id]
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html {render :action => 'cause', :layout => 'dt/plain'}
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

  def integrate_facebook
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
          members = fbsession.users_getInfo(:uids=>member_ids, :fields=>["name","pic_square", "pic", "pic_small"]).user_list
          @fb_members = members.paginate({:page => params[:fb_page], :per_page => 24})
          @fb_user_in_group = true if member_ids.find{ |id| Integer(@fbid.to_s)==id}
        rescue
          @fb_group_available = false
        end
      end
    end
  end
end
